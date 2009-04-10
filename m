From: Zhenwen Xu <helight.xu@gmail.com>
Subject: [PATCH]fix a warning on drivers/net/via-velocity.c
Date: Fri, 10 Apr 2009 21:11:57 +0800
Message-ID: <20090410131157.GA10063@helight>
Reply-To: Zhenwen Xu <helight.xu@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.190]:16922 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756796AbZDJNNU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2009 09:13:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix this waring:

drivers/net/via-velocity.c: In function =E2=80=98velocity_open=E2=80=99=
:
drivers/net/via-velocity.c:1924: warning: passing argument 2 of =E2=80=98=
request_irq=E2=80=99 from incompatible pointer type


=46rom daa9a8764a7a4261597a6b75230b9029d7723336 Mon Sep 17 00:00:00 200=
1
=46rom: Zhenwen Xu <Helight.Xu@gmail.com>
Date: Fri, 10 Apr 2009 21:06:39 +0800
Subject: [PATCH] fix a warning on drivers/net/via-velocity.c

Signed-off-by: Zhenwen Xu <helight.xu@gmail.com>
---
 drivers/net/via-velocity.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index fb53ef8..754a4b1 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -377,7 +377,7 @@ static void velocity_print_info(struct velocity_inf=
o *vptr);
 static int velocity_open(struct net_device *dev);
 static int velocity_change_mtu(struct net_device *dev, int mtu);
 static int velocity_xmit(struct sk_buff *skb, struct net_device *dev);
-static int velocity_intr(int irq, void *dev_instance);
+static irqreturn_t velocity_intr(int irq, void *dev_instance);
 static void velocity_set_multi(struct net_device *dev);
 static struct net_device_stats *velocity_get_stats(struct net_device *=
dev);
 static int velocity_ioctl(struct net_device *dev, struct ifreq *rq, in=
t cmd);
@@ -2215,7 +2215,7 @@ out:
  *	efficiently as possible.
  */
=20
-static int velocity_intr(int irq, void *dev_instance)
+static irqreturn_t velocity_intr(int irq, void *dev_instance)
 {
 	struct net_device *dev =3D dev_instance;
 	struct velocity_info *vptr =3D netdev_priv(dev);
--=20
1.5.6.5

--=20
---------------------------------
Zhenwen Xu - Open and Free
Home Page:	http://zhwen.org
My Studio:	http://dim4.cn
