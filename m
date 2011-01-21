From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: netif_setup_tc() is static
Date: Fri, 21 Jan 2011 06:18:08 +0100
Message-ID: <1295587088.2613.51.camel@edumazet-laptop>
References: <20110117175542.29543.38690.stgit@jf-dev1-dcblab>
	 <20110117180604.29543.38660.stgit@jf-dev1-dcblab>
	 <20110119.234132.176672734.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bhutchings@solarflare.com, jarkao2@gmail.com, hadi@cyberus.ca,
	shemminger@vyatta.com, tgraf@infradead.org, nhorman@tuxdriver.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:48131 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750695Ab1AUFSO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jan 2011 00:18:14 -0500
Received: by wwa36 with SMTP id 36so1488517wwa.1
        for <netdev@vger.kernel.org>; Thu, 20 Jan 2011 21:18:13 -0800 (PST)
In-Reply-To: <20110119.234132.176672734.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 19 janvier 2011 =C3=A0 23:41 -0800, David Miller a =C3=A9cr=
it :
> From: John Fastabend <john.r.fastabend@intel.com>
> Date: Mon, 17 Jan 2011 10:06:04 -0800
>=20
> > This patch provides a mechanism for lower layer devices to
> > steer traffic using skb->priority to tx queues.
>  ...
> > Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>=20
> Applied.

Hi John

Should netif_setup_tc() be static, or is it meant to be exported
somehow ?

[PATCH net-next-2.6] net: netif_setup_tc() is static

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/core/dev.c b/net/core/dev.c
index 2730352..47d3d78 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1605,7 +1605,7 @@ static void dev_queue_xmit_nit(struct sk_buff *sk=
b, struct net_device *dev)
  * expected that drivers will fix this mapping if they can before
  * calling netif_set_real_num_tx_queues.
  */
-void netif_setup_tc(struct net_device *dev, unsigned int txq)
+static void netif_setup_tc(struct net_device *dev, unsigned int txq)
 {
 	int i;
 	struct netdev_tc_txq *tc =3D &dev->tc_to_txq[0];


