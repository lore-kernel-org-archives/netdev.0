From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 3/4][ATM]: [suni] change suni_init to __devinit
Date: Wed, 28 Jun 2006 09:45:04 -0400
Message-ID: <200606281345.k5SDj4Ob008943@relax.cmf.nrl.navy.mil>
Cc: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:17377 "EHLO
	ginger.cmf.nrl.navy.mil") by vger.kernel.org with ESMTP
	id S1423325AbWF1NpN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 09:45:13 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

please consider for 2.6.18 -- thanks!

[ATM]: [suni] change suni_init to __devinit

Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

---
commit 4768199f3a5582378164820cc74251e485a01292
tree fd27293baebffd029ae53a6efe18913cfb68cada
parent 3d63ef0340a7f49a72f5eaa33f08b38fa78d48e1
author chas williams <chas@relax.cmf.nrl.navy.mil> Mon, 26 Jun 2006 19:56:00 -0400
committer chas williams <chas@relax.cmf.nrl.navy.mil> Mon, 26 Jun 2006 19:56:00 -0400

 drivers/atm/he.c   |    2 +-
 drivers/atm/suni.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index fde9334..a486eb1 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -1018,7 +1018,7 @@ he_init_irq(struct he_dev *he_dev)
 	return 0;
 }
 
-static int __init
+static int __devinit
 he_start(struct atm_dev *dev)
 {
 	struct he_dev *he_dev;
diff --git a/drivers/atm/suni.c b/drivers/atm/suni.c
index b1d063c..f04f39c 100644
--- a/drivers/atm/suni.c
+++ b/drivers/atm/suni.c
@@ -289,7 +289,7 @@ static const struct atmphy_ops suni_ops 
 };
 
 
-int suni_init(struct atm_dev *dev)
+int __devinit suni_init(struct atm_dev *dev)
 {
 	unsigned char mri;
 
