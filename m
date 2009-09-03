From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6]  net: net/core/dev.c cleanups
Date: Thu, 03 Sep 2009 14:03:09 +0200
Message-ID: <4A9FB07D.5000509@gmail.com>
References: <4A9F7BFC.5000401@gmail.com> <20090903115026.GD2885@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:60618 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753764AbZICMDU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 08:03:20 -0400
In-Reply-To: <20090903115026.GD2885@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko a =E9crit :
> Hmm, this patch causes following warnings for me:
>=20
> eth%d dev=3Dffff88007b9dc000 queue_count=3D1 tx=3Dffff88007c565e00

Oops !

Sorry, I left a debugging aid :(

Thanks Jiri

[PATCH net-next-2.6] net: Remove debugging code

Remove a debugging aid I accidently left in previous 'cleanup' patch

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/core/dev.c b/net/core/dev.c
index dd94ae6..1a6561b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5155,8 +5155,6 @@ struct net_device *alloc_netdev_mq(int sizeof_pri=
v, const char *name,
 	}
=20
 	dev =3D PTR_ALIGN(p, NETDEV_ALIGN);
-	pr_err("%s dev=3D%p queue_count=3D%d tx=3D%p\n", name, dev, queue_cou=
nt, tx);
-	WARN_ON(queue_count =3D=3D 1);
 	dev->padded =3D (char *)dev - (char *)p;
=20
 	if (dev_addr_init(dev))
