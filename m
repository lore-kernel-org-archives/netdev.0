From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] ipv6: make fragment identifications less
 predictable
Date: Wed, 20 Jul 2011 10:25:27 +0200
Message-ID: <1311150327.2338.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4E24BE94.7010301@gont.com.ar>
	 <1311082696.2375.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1311089463.2375.42.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1311108423.3113.24.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: security@kernel.org, Eugene Teo <eugeneteo@kernel.sg>,
	netdev <netdev@vger.kernel.org>, Matt Mackall <mpm@selenic.com>
To: Fernando Gont <fernando@gont.com.ar>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57376 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751101Ab1GTIZg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 04:25:36 -0400
Received: by wyg8 with SMTP id 8so3306190wyg.19
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2011 01:25:35 -0700 (PDT)
In-Reply-To: <1311108423.3113.24.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 19 juillet 2011 =C3=A0 22:47 +0200, Eric Dumazet a =C3=A9crit =
:
> IPv6 fragment identification generation is way beyond what we use for
> IPv4 : It uses a single generator. Its not scalable and allows DOS
> attacks.
>=20
> Now inetpeer is IPv6 aware, we can use it to provide a more secure an=
d
> scalable frag ident generator (per destination, instead of system wid=
e)
>=20
> This patch :
> 1) defines a new secure_ipv6_id() helper
> 2) extends inet_getid() to provide 32bit results
> 3) extends ipv6_select_ident() with a new dest parameter
>=20
> Reported-by: Fernando Gont <fernando@gont.com.ar>
> CC: Matt Mackall <mpm@selenic.com>
> CC: Eugene Teo <eugeneteo@kernel.sg>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---


Please hold on, I'll make a different patch series to ease stable teams
job. It appears inetpeer & ipv6 are really not an option for old
kernels.

Common patch for all kernels :
1) Fix the problem without inetpeer help
---=20
Patches for next kernels
2) random split as suggested by Matt Mackal
3) Use inetpeer cache to scale identification generation


