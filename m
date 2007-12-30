From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH net-2.6.25 7/7][ATM]: [he] fixing compilation when you define USE_RBPS_POOL/USE_RBPL_POOL
Date: Sat, 29 Dec 2007 20:08:30 -0500
Message-ID: <200712300108.lBU18UUa003635@cmf.nrl.navy.mil>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:59192 "EHLO
	ginger.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752628AbXL3BIo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2007 20:08:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 62024377f1da8a3f5b49cfd60d892c778f5a5741
Author: Jorge Boncompte <jorge@dti2.net>
Date:   Thu Dec 13 16:14:40 2007 -0500

    [ATM]: [he] fixing compilation when you define USE_RBPS_POOL/USE_RBPL_POOL
    
    Signed-off-by: Jorge Boncompte <jorge@dti2.net>
    Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index 3b64a99..20df4bb 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -1643,6 +1643,8 @@ he_stop(struct he_dev *he_dev)
 
 	if (he_dev->rbpl_base) {
 #ifdef USE_RBPL_POOL
+		int i;
+
 		for (i = 0; i < CONFIG_RBPL_SIZE; ++i) {
 			void *cpuaddr = he_dev->rbpl_virt[i].virt;
 			dma_addr_t dma_handle = he_dev->rbpl_base[i].phys;
@@ -1665,6 +1667,8 @@ he_stop(struct he_dev *he_dev)
 #ifdef USE_RBPS
 	if (he_dev->rbps_base) {
 #ifdef USE_RBPS_POOL
+		int i;
+
 		for (i = 0; i < CONFIG_RBPS_SIZE; ++i) {
 			void *cpuaddr = he_dev->rbps_virt[i].virt;
 			dma_addr_t dma_handle = he_dev->rbps_base[i].phys;
