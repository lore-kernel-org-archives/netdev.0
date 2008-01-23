From: Jens Osterkamp <jens@de.ibm.com>
Subject: Re: [Cbe-oss-dev] [PATCH 1/5] spidernet: add missing initialization
Date: Wed, 23 Jan 2008 14:53:42 +0100
Message-ID: <200801231453.42736.jens@de.ibm.com>
References: <20080111.153859.-1300526764.kouish@swc.toshiba.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>, netdev@vger.kernel.org
To: cbe-oss-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:51496 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130AbYAWNxp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 08:53:45 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.13.8/8.13.8) with ESMTP id m0NDriJA035934
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2008 13:53:44 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0NDrhqe1118350
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2008 14:53:43 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0NDrhGY010738
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2008 14:53:43 +0100
In-Reply-To: <20080111.153859.-1300526764.kouish@swc.toshiba.co.jp>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 11 January 2008, Ishizaki Kou wrote:
> This patch fixes initialization of "aneg_count" and "medium" fields i=
n
> spider_net_card to make spidernet driver correctly sets "link status"=
=2E
>=20
> Signed-off-by: Kou Ishizaki <kou.ishizaki@toshiba.co.jp>

Acked-by: Jens Osterkamp <jens@de.ibm.com>

> ---
>=20
> Index: linux-powerpc-git/drivers/net/spider_net.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-powerpc-git.orig/drivers/net/spider_net.c
> +++ linux-powerpc-git/drivers/net/spider_net.c
> @@ -1399,6 +1399,8 @@ spider_net_link_reset(struct net_device=20
>  	spider_net_write_reg(card, SPIDER_NET_GMACINTEN, 0);
>=20
>  	/* reset phy and setup aneg */
> +	card->aneg_count =3D 0;
> +	card->medium =3D BCM54XX_COPPER;
>  	spider_net_setup_aneg(card);
>  	mod_timer(&card->aneg_timer, jiffies + SPIDER_NET_ANEG_TIMER);
>=20
> @@ -1982,6 +1984,8 @@ spider_net_open(struct net_device *netde
>  		goto init_firmware_failed;
>=20
>  	/* start probing with copper */
> +	card->aneg_count =3D 0;
> +	card->medium =3D BCM54XX_COPPER;
>  	spider_net_setup_aneg(card);
>  	if (card->phy.def->phy_id)
>  		mod_timer(&card->aneg_timer, jiffies + SPIDER_NET_ANEG_TIMER);
> _______________________________________________
> cbe-oss-dev mailing list
> cbe-oss-dev@ozlabs.org
> https://ozlabs.org/mailman/listinfo/cbe-oss-dev
>
--=20

Gru=DF,

Jens

IBM Deutschland Entwicklung GmbH
Vorsitzender des Aufsichtsrats: Martin Jetter
Gesch=E4ftsf=FChrung: Herbert Kircher=20
Sitz der Gesellschaft: B=F6blingen
Registergericht: Amtsgericht Stuttgart, HRB 243294
