From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] ipv6: make fragment identifications less
 predictable
Date: Wed, 20 Jul 2011 08:50:48 +0200
Message-ID: <1311144648.3113.114.camel@edumazet-laptop>
References: <4E24BE94.7010301@gont.com.ar>
	 <1311082696.2375.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1311089463.2375.42.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1311108423.3113.24.camel@edumazet-laptop> <1311109019.14555.11.camel@calx>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fernando Gont <fernando@gont.com.ar>,
	David Miller <davem@davemloft.net>, security@kernel.org,
	Eugene Teo <eugeneteo@kernel.sg>,
	netdev <netdev@vger.kernel.org>
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:57023 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750769Ab1GTGuy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 02:50:54 -0400
Received: by wwg11 with SMTP id 11so4456841wwg.1
        for <netdev@vger.kernel.org>; Tue, 19 Jul 2011 23:50:52 -0700 (PDT)
In-Reply-To: <1311109019.14555.11.camel@calx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 19 juillet 2011 =C3=A0 15:56 -0500, Matt Mackall a =C3=A9crit =
:
> On Tue, 2011-07-19 at 22:47 +0200, Eric Dumazet wrote:
> > IPv6 fragment identification generation is way beyond what we use f=
or
> > IPv4 : It uses a single generator. Its not scalable and allows DOS
> > attacks.
> >=20
> > Now inetpeer is IPv6 aware, we can use it to provide a more secure =
and
> > scalable frag ident generator (per destination, instead of system w=
ide)
>=20
> This code really needs to get moved out of random.c and into net/. Ot=
her
> than that, looks fine to me.

Sure. Can we agree to make this cleanup later ?

I added secure_ipv6_id() right after secure_ip_id() because it sounded
the right place ;)



