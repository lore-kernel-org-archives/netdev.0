From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 11/13] stmmac: include netdevice.h into the common.h header
Date: Thu,  7 Jan 2010 10:07:21 +0100
Message-ID: <1262855243-6762-11-git-send-email-peppe.cavallaro@st.com>
References: <1262855243-6762-1-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-2-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-3-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-4-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-5-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-6-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-7-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-8-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-9-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-10-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:58115 "EHLO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756352Ab0AGJHc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 04:07:32 -0500
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id D237819D
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2010 09:07:28 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 94085BE2
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2010 09:07:28 +0000 (GMT)
In-Reply-To: <1262855243-6762-10-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/common.h      |    2 +-
 drivers/net/stmmac/dwmac100.c    |    1 -
 drivers/net/stmmac/dwmac1000.h   |    1 -
 drivers/net/stmmac/stmmac_main.c |    1 -
 drivers/net/stmmac/stmmac_mdio.c |    1 -
 5 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/drivers/net/stmmac/common.h b/drivers/net/stmmac/common.h
index 25b53d4..7267bcd 100644
--- a/drivers/net/stmmac/common.h
+++ b/drivers/net/stmmac/common.h
@@ -23,7 +23,7 @@
 *******************************************************************************/
 
 #include "descs.h"
-#include <linux/io.h>
+#include <linux/netdevice.h>
 
 struct stmmac_extra_stats {
 	/* Transmit errors */
diff --git a/drivers/net/stmmac/dwmac100.c b/drivers/net/stmmac/dwmac100.c
index 010c8b2..82dde77 100644
--- a/drivers/net/stmmac/dwmac100.c
+++ b/drivers/net/stmmac/dwmac100.c
@@ -26,7 +26,6 @@
   Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
 *******************************************************************************/
 
-#include <linux/netdevice.h>
 #include <linux/crc32.h>
 #include <linux/mii.h>
 #include <linux/phy.h>
diff --git a/drivers/net/stmmac/dwmac1000.h b/drivers/net/stmmac/dwmac1000.h
index 3d54d6c..62dca0e 100644
--- a/drivers/net/stmmac/dwmac1000.h
+++ b/drivers/net/stmmac/dwmac1000.h
@@ -20,7 +20,6 @@
   Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
 *******************************************************************************/
 
-#include <linux/netdevice.h>
 #include <linux/phy.h>
 #include "common.h"
 
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index 16d4e1c..a673361 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -32,7 +32,6 @@
 #include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/interrupt.h>
-#include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/platform_device.h>
 #include <linux/ip.h>
diff --git a/drivers/net/stmmac/stmmac_mdio.c b/drivers/net/stmmac/stmmac_mdio.c
index 131e0a6..fffe1d0 100644
--- a/drivers/net/stmmac/stmmac_mdio.c
+++ b/drivers/net/stmmac/stmmac_mdio.c
@@ -24,7 +24,6 @@
   Maintainer: Giuseppe Cavallaro <peppe.cavallaro@st.com>
 *******************************************************************************/
 
-#include <linux/netdevice.h>
 #include <linux/mii.h>
 #include <linux/phy.h>
 
-- 
1.6.0.4

