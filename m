From: Jens Osterkamp <jens@de.ibm.com>
Subject: Re: [Cbe-oss-dev] [PATCH 3/5] spidernet: change interrupt masks
Date: Wed, 23 Jan 2008 14:55:02 +0100
Message-ID: <200801231455.03187.jens@de.ibm.com>
References: <20080111.154343.-1625861724.kouish@swc.toshiba.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>, netdev@vger.kernel.org
To: cbe-oss-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:48562 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751928AbYAWNzF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 08:55:05 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.8/8.13.8) with ESMTP id m0NDt4li210102
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2008 13:55:04 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0NDt4EM1282050
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2008 14:55:04 +0100
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0NDt3fh000740
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2008 14:55:04 +0100
In-Reply-To: <20080111.154343.-1625861724.kouish@swc.toshiba.co.jp>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 11 January 2008, Ishizaki Kou wrote:
> This patch changes spidernet interrupt masks.
>=20
>  - unmask GDAINVAINT. There is an operation to do by spidernet
>    interrupt handler.
>  - mask some interrupts. There are no operations in the interrupt han=
dler.
>=20
> Signed-off-by: Kou Ishizaki <kou.ishizaki@toshiba.co.jp>

Acked-by: Jens Osterkamp <jens@de.ibm.com>

> ---
>=20
> Index: linux-powerpc-git/drivers/net/spider_net.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-powerpc-git.orig/drivers/net/spider_net.h
> +++ linux-powerpc-git/drivers/net/spider_net.h
> @@ -159,9 +159,8 @@ extern char spider_net_driver_name[];
>=20
>  /** interrupt mask registers */
>  #define SPIDER_NET_INT0_MASK_VALUE	0x3f7fe2c7
> -#define SPIDER_NET_INT1_MASK_VALUE	0xffff7ff7
> -/* no MAC aborts -> auto retransmission */
> -#define SPIDER_NET_INT2_MASK_VALUE	0xffef7ff1
> +#define SPIDER_NET_INT1_MASK_VALUE	0x0000fff2
> +#define SPIDER_NET_INT2_MASK_VALUE	0x000003f1
>=20
>  /* we rely on flagged descriptor interrupts */
>  #define SPIDER_NET_FRAMENUM_VALUE	0x00000000
> _______________________________________________
> cbe-oss-dev mailing list
> cbe-oss-dev@ozlabs.org
> https://ozlabs.org/mailman/listinfo/cbe-oss-dev
>=20



--=20

Gru=DF,

Jens

IBM Deutschland Entwicklung GmbH
Vorsitzender des Aufsichtsrats: Martin Jetter
Gesch=E4ftsf=FChrung: Herbert Kircher=20
Sitz der Gesellschaft: B=F6blingen
Registergericht: Amtsgericht Stuttgart, HRB 243294
