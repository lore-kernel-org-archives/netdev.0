From: jamal <hadi@cyberus.ca>
Subject: Re: SMP issues on ingress queue grafting
Date: Thu, 4 Jul 2002 14:12:34 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0207041409520.26922-100000@shell.cyberus.ca>
References: <20020704144142.GC12749@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: bert hubert <ahu@ds9a.nl>
In-Reply-To: <20020704144142.GC12749@outpost.ds9a.nl>
List-Id: netdev.vger.kernel.org


Maybe related to what Doron was seeing:
Theres a patch thats been sitting around for a year or so;

http://www.cyberus.ca/~hadi/patches/ing-stats.patch

hopefuly the patch would be in 2.4.19 when it comes out. Ask him to test
it out.

cheers,
jamal

On Thu, 4 Jul 2002, bert hubert wrote:

> Alexey, Werner, Jamal, Others,
>
> On 2.4.18-ac3 SMP, Dimitris Zilaskos reports that he can reliably hang his
> system with the following two line script repeated during heavy traffic.
>
> Full thread starts here:
> http://mailman.ds9a.nl/pipermail/lartc/2002q3/004316.html
>
> Hope this points you to any problems.
>
> Regards,
>
> bert
>
> ----- Forwarded message from Dimitris Zilaskos <dzila@tassadar.physics.auth.gr> -----
>
> From: Dimitris Zilaskos <dzila@tassadar.physics.auth.gr>
> To: Stef Coene <stef.coene@docum.org>
> Cc: lartc@mailman.ds9a.nl
> Subject: Re: [LARTC] tc reliably hangs my system
> Date: Thu, 4 Jul 2002 13:07:08 +0300 (EEST)
>
>
>  ok , this 2 lines repated anything from 5 to 20 times cause the hang :
>
> tc qdisc del dev eth0 ingress
> tc qdisc add dev eth0 handle ffff: ingress
>
>  again , the presence of sustained outgoing traffic catalyses the effect .
> It takes at least 150-200 kbytes/sec to easily cause the hang .
>
>  Regards ,
>
> --
> =============================================================================
>
> Dimitris Zilaskos
>
> Department of Physics @ Aristotle Univercity of Thessaloniki , Greece
> =============================================================================
>
> _______________________________________________
> LARTC mailing list / LARTC@mailman.ds9a.nl
> http://mailman.ds9a.nl/mailman/listinfo/lartc HOWTO: http://lartc.org/
>
>
> ----- End forwarded message -----
>
> --
> http://www.PowerDNS.com          Versatile DNS Software & Services
> http://www.tk                              the dot in .tk
> http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
>
