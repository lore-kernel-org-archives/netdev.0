From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] drivers/net: use IS_ENABLED(CONFIG_IPV6)
Date: Sat, 10 Dec 2011 23:29:34 +0100
Message-ID: <1323556174.4016.35.camel@edumazet-laptop>
References: <4EE32777.2030003@parallels.com>
	 <4EE327CB.4040505@parallels.com> <1323514931.4016.17.camel@edumazet-laptop>
	 <20111210.131555.2025649575447940902.davem@davemloft.net>
	 <1323546511.4016.32.camel@edumazet-laptop>
	 <1323554422.29470.4.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:34986 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751351Ab1LJW3i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Dec 2011 17:29:38 -0500
Received: by eaak14 with SMTP id k14so2284003eaa.19
        for <netdev@vger.kernel.org>; Sat, 10 Dec 2011 14:29:37 -0800 (PST)
In-Reply-To: <1323554422.29470.4.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 10 d=C3=A9cembre 2011 =C3=A0 14:00 -0800, Joe Perches a =C3=A9=
crit :
> Instead of testing defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE=
)
>=20
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>=20
> Here's the same for drivers/net/
>=20
>  drivers/net/ethernet/broadcom/cnic.c   |    2 +-
>  drivers/net/wireless/ipw2x00/ipw2100.c |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ether=
net/broadcom/cnic.c
> index 4bcb67e..757b981 100644
> --- a/drivers/net/ethernet/broadcom/cnic.c
> +++ b/drivers/net/ethernet/broadcom/cnic.c
> @@ -3516,7 +3516,7 @@ static int cnic_get_v4_route(struct sockaddr_in=
 *dst_addr,
>  static int cnic_get_v6_route(struct sockaddr_in6 *dst_addr,
>  			     struct dst_entry **dst)
>  {
> -#if defined(CONFIG_IPV6) || (defined(CONFIG_IPV6_MODULE) && defined(=
MODULE))
> +#if IS_ENABLED(CONFIG_IPV6)

Are you sure this is equivalent ?
