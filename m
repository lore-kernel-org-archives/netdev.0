From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 2/4][ATM]: [iphase] should be __devinit not __init
Date: Wed, 28 Jun 2006 09:44:45 -0400
Message-ID: <200606281344.k5SDij70008930@relax.cmf.nrl.navy.mil>
Cc: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:16097 "EHLO
	ginger.cmf.nrl.navy.mil") by vger.kernel.org with ESMTP
	id S1423324AbWF1Noy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 09:44:54 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

please consider for 2.6.18 -- thanks!

[ATM]: [iphase] should be __devinit not __init

Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

---
commit a6d3f9a19cc29d6ece38f057eb896c16a4372129
tree 109e40a1fb873f0105bb75ecf21456f25b1756ef
parent 51403ade3cedfc85f1f41d81cb3a227f9ce2366f
author chas williams <chas@relax.cmf.nrl.navy.mil> Sun, 28 May 2006 22:22:31 -0400
committer chas williams <chas@relax.cmf.nrl.navy.mil> Sun, 28 May 2006 22:22:31 -0400

 drivers/atm/iphase.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/atm/iphase.c b/drivers/atm/iphase.c
index 42eb86f..d41196b 100644
--- a/drivers/atm/iphase.c
+++ b/drivers/atm/iphase.c
@@ -2283,7 +2283,7 @@ static int reset_sar(struct atm_dev *dev
 }  
 	  
 	  
-static int __init ia_init(struct atm_dev *dev)
+static int __devinit ia_init(struct atm_dev *dev)
 {  
 	IADEV *iadev;  
 	unsigned long real_base;
@@ -2479,7 +2479,7 @@ static void ia_free_rx(IADEV *iadev)
 			  iadev->rx_dle_dma);  
 }
 
-static int __init ia_start(struct atm_dev *dev)
+static int __devinit ia_start(struct atm_dev *dev)
 {  
 	IADEV *iadev;  
 	int error;  
