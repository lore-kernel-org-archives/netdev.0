From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5 2/2] Implement IPV6_UNICAST_IF socket option.
Date: Tue, 07 Feb 2012 21:03:13 +0100
Message-ID: <1328644993.2457.2.camel@edumazet-laptop>
References: <1328643863-10404-2-git-send-email-ehoover@mines.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev <netdev@vger.kernel.org>
To: "Erich E. Hoover" <ehoover@mines.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:55524 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755661Ab2BGUDT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 15:03:19 -0500
Received: by wics10 with SMTP id s10so5175763wic.19
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2012 12:03:18 -0800 (PST)
In-Reply-To: <1328643863-10404-2-git-send-email-ehoover@mines.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 07 f=C3=A9vrier 2012 =C3=A0 12:44 -0700, Erich E. Hoover a =C3=
=A9crit :
> The IPV6_UNICAST_IF feature is the IPv6 compliment to IP_UNICAST_IF.
>=20
> Signed-off-by: Erich E. Hoover <ehoover@mines.edu>
> ---
>  include/linux/in6.h      |    1 +
>  include/linux/ipv6.h     |    1 +
>  net/ipv6/icmp.c          |    4 ++++
>  net/ipv6/ipv6_sockglue.c |   34 ++++++++++++++++++++++++++++++++++
>  net/ipv6/raw.c           |    2 ++
>  net/ipv6/udp.c           |    3 ++-
>  6 files changed, 44 insertions(+), 1 deletions(-)
>=20
> diff --git a/include/linux/in6.h b/include/linux/in6.h
> index 097a34b..a67d76e 100644
> --- a/include/linux/in6.h
> +++ b/include/linux/in6.h
> @@ -163,6 +163,7 @@ struct in6_flowlabel_req {
>  #define IPV6_NEXTHOP		9
>  #define IPV6_AUTHHDR		10	/* obsolete */
>  #define IPV6_FLOWINFO		11
> +#define IPV6_UNICAST_IF		12
> =20

Hmm, last entry is :

#define IPV6_TRANSPARENT        75=20

So 76 for your new option would be better
