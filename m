From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [0/8] netpoll/bridge fixes
Date: Mon, 19 Jul 2010 18:52:36 +0200
Message-ID: <1279558356.2553.145.camel@edumazet-laptop>
References: <20100719101904.GA31743@redhat.com>
	 <20100719105300.GA22179@gondor.apana.org.au>
	 <20100719115411.GA22758@gondor.apana.org.au>
	 <20100719.090503.73693858.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, mst@redhat.com, shemminger@vyatta.com,
	frzhang@redhat.com, netdev@vger.kernel.org, amwang@redhat.com,
	mpm@selenic.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:48642 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740Ab0GSQwl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 12:52:41 -0400
Received: by wyb42 with SMTP id 42so4571997wyb.19
        for <netdev@vger.kernel.org>; Mon, 19 Jul 2010 09:52:40 -0700 (PDT)
In-Reply-To: <20100719.090503.73693858.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 19 juillet 2010 =C3=A0 09:05 -0700, David Miller a =C3=A9crit =
:

> I thought we did that already.... oh I see, we did it for bonding:
>=20
> commit c22d7ac844f1cb9c6a5fd20f89ebadc2feef891b
> Author: Andy Gospodarek <andy@greyhouse.net>
> Date:   Fri Jun 25 09:50:44 2010 +0000
>=20

BTW, this added following warning :


[PATCH] bonding: avoid a warning

drivers/net/bonding/bond_main.c:179:12: warning: =E2=80=98disable_netpo=
ll=E2=80=99
defined but not used

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index 8228088..20f45cb 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -176,7 +176,9 @@ static int arp_ip_count;
 static int bond_mode	=3D BOND_MODE_ROUNDROBIN;
 static int xmit_hashtype =3D BOND_XMIT_POLICY_LAYER2;
 static int lacp_fast;
+#ifdef CONFIG_NET_POLL_CONTROLLER
 static int disable_netpoll =3D 1;
+#endif
=20
 const struct bond_parm_tbl bond_lacp_tbl[] =3D {
 {	"slow",		AD_LACP_SLOW},


