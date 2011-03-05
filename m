From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: Use passed-in protocol in ip_route_newports().
Date: Sat, 05 Mar 2011 07:49:09 +0100
Message-ID: <1299307749.2758.68.camel@edumazet-laptop>
References: <20110304.213553.71108798.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:63311 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750982Ab1CEGtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2011 01:49:13 -0500
Received: by wyg36 with SMTP id 36so2836265wyg.19
        for <netdev@vger.kernel.org>; Fri, 04 Mar 2011 22:49:11 -0800 (PST)
In-Reply-To: <20110304.213553.71108798.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 04 mars 2011 =C3=A0 21:35 -0800, David Miller a =C3=A9crit =
:
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  include/net/route.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/include/net/route.h b/include/net/route.h
> index 60daf74..8905d90 100644
> --- a/include/net/route.h
> +++ b/include/net/route.h
> @@ -217,7 +217,7 @@ static inline struct rtable *ip_route_newports(st=
ruct rtable *rt,
>  				    .fl4_dst =3D rt->fl.fl4_dst,
>  				    .fl4_src =3D rt->fl.fl4_src,
>  				    .fl4_tos =3D rt->fl.fl4_tos,
> -				    .proto =3D rt->fl.proto,
> +				    .proto =3D protocol,
>  				    .fl_ip_sport =3D sport,
>  				    .fl_ip_dport =3D dport };
> =20

Reviewed-by: Eric Dumazet <eric.dumazet@gmail.com>



