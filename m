From: Jens Osterkamp <jens@de.ibm.com>
Subject: Re: [Cbe-oss-dev] [PATCH 2/5] spidernet: increase auto-negotiation timeout to 5 seconds
Date: Wed, 23 Jan 2008 14:54:04 +0100
Message-ID: <200801231454.05109.jens@de.ibm.com>
References: <20080111.154125.-1350516935.kouish@swc.toshiba.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>, netdev@vger.kernel.org
To: cbe-oss-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:54803 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751535AbYAWNyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 08:54:07 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.8/8.13.8) with ESMTP id m0NDs6cf150572
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2008 13:54:06 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0NDs5aw1253504
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2008 14:54:05 +0100
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0NDs5a9008604
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2008 14:54:05 +0100
In-Reply-To: <20080111.154125.-1350516935.kouish@swc.toshiba.co.jp>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 11 January 2008, Ishizaki Kou wrote:
> This patch extends the timeout for spidernet auto-negotiation.
> Auto-negotiation often fails to finish in 2 seconds.
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
> @@ -52,7 +52,7 @@ extern char spider_net_driver_name[];
>=20
>  #define SPIDER_NET_TX_TIMER			(HZ/5)
>  #define SPIDER_NET_ANEG_TIMER			(HZ)
> -#define SPIDER_NET_ANEG_TIMEOUT			2
> +#define SPIDER_NET_ANEG_TIMEOUT			5
>=20
>  #define SPIDER_NET_RX_CSUM_DEFAULT		1
>=20
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
