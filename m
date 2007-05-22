From: Li Yang <leoli@freescale.com>
Subject: [PATCH 2/2] ucc_geth:trivial fix
Date: Tue, 22 May 2007 20:34:14 +0800
Message-ID: <4652E346.4080900@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:46912 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756142AbXEVMcc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2007 08:32:32 -0400
Received: from az33smr02.freescale.net (az33smr02.freescale.net [10.64.34.200])
	by az33egw01.freescale.net (8.12.11/az33egw01) with ESMTP id l4MCWTZB007018
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 05:32:30 -0700 (MST)
Received: from zch01exm20.fsl.freescale.net (zch01exm20.ap.freescale.net [10.192.129.204])
	by az33smr02.freescale.net (8.13.1/8.13.0) with ESMTP id l4MCWSZv027151
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 07:32:29 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove redundant includes.

Signed-off-by: Li Yang <leoli@freescale.com>
---
 drivers/net/ucc_geth.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 864b1aa..3b27b6d 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -23,11 +23,8 @@
 #include <linux/skbuff.h>
 #include <linux/spinlock.h>
 #include <linux/mm.h>
-#include <linux/ethtool.h>
-#include <linux/delay.h>
 #include <linux/dma-mapping.h>
 #include <linux/fsl_devices.h>
-#include <linux/ethtool.h>
 #include <linux/mii.h>
 #include <linux/phy.h>
 #include <linux/workqueue.h>

