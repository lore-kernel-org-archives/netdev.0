From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 1/4][ATM]: [idt77105] should be __devinit not __init
Date: Wed, 28 Jun 2006 09:44:27 -0400
Message-ID: <200606281344.k5SDiR0D008917@relax.cmf.nrl.navy.mil>
Cc: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:14305 "EHLO
	ginger.cmf.nrl.navy.mil") by vger.kernel.org with ESMTP
	id S1423322AbWF1Nok (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 09:44:40 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

please consider for 2.6.18 -- thanks!

[ATM]: [idt77105] should be __devinit not __init

Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

---
commit 51403ade3cedfc85f1f41d81cb3a227f9ce2366f
tree f9cf0143466de92eda0080e27240d4b53c130c18
parent 982703b5b38b314081d79ebc657fc06b1b6fe6b6
author chas williams <chas@relax.cmf.nrl.navy.mil> Sun, 28 May 2006 22:14:23 -0400
committer chas williams <chas@relax.cmf.nrl.navy.mil> Sun, 28 May 2006 22:14:23 -0400

 drivers/atm/idt77105.c |    2 +-
 drivers/atm/idt77105.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/atm/idt77105.c b/drivers/atm/idt77105.c
index 0aabfc2..325325a 100644
--- a/drivers/atm/idt77105.c
+++ b/drivers/atm/idt77105.c
@@ -358,7 +358,7 @@ static const struct atmphy_ops idt77105_
 };
 
 
-int idt77105_init(struct atm_dev *dev)
+int __devinit idt77105_init(struct atm_dev *dev)
 {
 	dev->phy = &idt77105_ops;
 	return 0;
diff --git a/drivers/atm/idt77105.h b/drivers/atm/idt77105.h
index 8ba8218..3fd2bc8 100644
--- a/drivers/atm/idt77105.h
+++ b/drivers/atm/idt77105.h
@@ -76,7 +76,7 @@ #define IDT77105_CTRSEL_RCC	0x02	/* W, R
 #define IDT77105_CTRSEL_RHEC	0x01	/* W, Rx HEC Error Counter */
 
 #ifdef __KERNEL__
-int idt77105_init(struct atm_dev *dev) __init;
+int idt77105_init(struct atm_dev *dev);
 #endif
 
 /*
