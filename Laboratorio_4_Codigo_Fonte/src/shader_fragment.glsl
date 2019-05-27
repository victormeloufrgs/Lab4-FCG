#version 330 core

// Atributos de fragmentos recebidos como entrada ("in") pelo Fragment Shader.
// Neste exemplo, este atributo foi gerado pelo rasterizador como a
// interpola��o da posi��o global e a normal de cada v�rtice, definidas em
// "shader_vertex.glsl" e "main.cpp".
in vec4 position_world;
in vec4 normal;

// Matrizes computadas no c�digo C++ e enviadas para a GPU
uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

// Identificador que define qual objeto est� sendo desenhado no momento
#define SPHERE 0
#define BUNNY  1
#define PLANE  2
uniform int object_id;

// O valor de sa�da ("out") de um Fragment Shader � a cor final do fragmento.
out vec3 color;

void main()
{
    // Obtemos a posi��o da c�mera utilizando a inversa da matriz que define o
    // sistema de coordenadas da c�mera.
    vec4 origin = vec4(0.0, 0.0, 0.0, 1.0);
    vec4 camera_position = inverse(view) * origin;

    // O fragmento atual � coberto por um ponto que percente � superf�cie de um
    // dos objetos virtuais da cena. Este ponto, p, possui uma posi��o no
    // sistema de coordenadas global (World coordinates). Esta posi��o � obtida
    // atrav�s da interpola��o, feita pelo rasterizador, da posi��o de cada
    // v�rtice.
    vec4 p = position_world;

    // Normal do fragmento atual, interpolada pelo rasterizador a partir das
    // normais de cada v�rtice.
    vec4 n = normalize(normal);

    // Vetor que define o sentido da fonte de luz em rela��o ao ponto atual.
    vec4 l = normalize(vec4(1.0,1.0,0.5,0.0));

    vec4 l_spotlight = vec4(0.0,2.0,1.0,1.0);
    vec4 v_spotlight = vec4(0.0,-1.0,0.0,1.0);
    float a_spotlight = radians(30);

    // Vetor que define o sentido da c�mera em rela��o ao ponto atual.
    vec4 v = normalize(camera_position - p);

    // Vetor que define o sentido da reflex�o especular ideal.
    //vec4 r = vec4(0.0,0.0,0.0,0.0); // PREENCHA AQUI o vetor de reflex�o especular ideal
    vec4 r = -l+2*n*dot(n,l);

    // Par�metros que definem as propriedades espectrais da superf�cie
    vec3 Kd; // Reflet�ncia difusa
    vec3 Ks; // Reflet�ncia especular
    vec3 Ka; // Reflet�ncia ambiente
    float q; // Expoente especular para o modelo de ilumina��o de Phong

    if ( object_id == SPHERE )
    {
        // PREENCHA AQUI
        // Propriedades espectrais da esfera
        Kd = vec3(0.8, 0.4, 0.08);
        Ks = vec3(0.0,0.0,0.0);
        Ka = vec3(0.4, 0.2, 0.04);
        q = 1.0;
    }
    else if ( object_id == BUNNY )
    {
        // PREENCHA AQUI
        // Propriedades espectrais do coelho
        Kd = vec3(0.08, 0.4, 0.8);
        Ks = vec3(0.8, 0.8, 0.8);
        Ka = vec3(0.04, 0.2, 0.4);
        q = 32.0;
    }
    else if ( object_id == PLANE )
    {
        // PREENCHA AQUI
        // Propriedades espectrais do plano
        Kd = vec3(0.2,0.2,0.2);
        Ks = vec3(0.3,0.3,0.3);
        Ka = vec3(0.0,0.0,0.0);
        q = 20.0;
    }
    else // Objeto desconhecido = preto
    {
        Kd = vec3(0.0,0.0,0.0);
        Ks = vec3(0.0,0.0,0.0);
        Ka = vec3(0.0,0.0,0.0);
        q = 1.0;
    }

    // Espectro da fonte de ilumina��o
    vec3 I = vec3(1.0,1.0,1.0); // PREENCH AQUI o espectro da fonte de luz

    // Espectro da luz ambiente
    vec3 Ia = vec3(0.2,0.2,0.2); // PREENCHA AQUI o espectro da luz ambiente

    // Termo difuso utilizando a lei dos cossenos de Lambert
    vec3 lambert_diffuse_term = Kd*I*max(0,dot(n,l))+Ka*Ia;//vec3(0.0,0.0,0.0); // PREENCHA AQUI o termo difuso de Lambert

    // Termo ambiente
    vec3 ambient_term = Ka*Ia;//vec3(0.0,0.0,0.0); // PREENCHA AQUI o termo ambiente

    // Termo especular utilizando o modelo de ilumina��o de Phong
    vec3 phong_specular_term  = Ks*I*max(0,pow(dot(r,v),q));//vec3(0.0,0.0,0.0); // PREENCH AQUI o termo especular de Phong

    // Cor final do fragmento calculada com uma combina��o dos termos difuso,
    // especular, e ambiente. Veja slide 133 do documento "Aula_17_e_18_Modelos_de_Iluminacao.pdf".
    color = vec3(0.0,0.0,0.0);//lambert_diffuse_term + phong_specular_term;
    // spotlight

    vec4 p_minus_l_vec = p - l_spotlight;
    vec4 v_spotlight_vector = v_spotlight;

    vec4 light_dir_test = p_minus_l_vec/length(p_minus_l_vec);
    vec4 v_spotlight_test = (v_spotlight_vector/length(v_spotlight_vector));

    if (dot(light_dir_test, v_spotlight_test) >= cos(a_spotlight)) {

        vec4 r_spotlight = -p_minus_l_vec+2*n*dot(n,p_minus_l_vec);

        color += Kd*I*max(0,dot(n,l_spotlight)) + Ks*I*max(0,dot(r_spotlight,v));
    }

    color += ambient_term;

    // Cor final com corre��o gamma, considerando monitor sRGB.
    // Veja https://en.wikipedia.org/w/index.php?title=Gamma_correction&oldid=751281772#Windows.2C_Mac.2C_sRGB_and_TV.2Fvideo_standard_gammas
    color = pow(color, vec3(1.0,1.0,1.0)/2.2);
}

