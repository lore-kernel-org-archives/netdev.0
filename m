From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 8/9] stmmac: update the doc with new info about the driver's debug (v2)
Date: Tue, 30 Aug 2011 16:21:03 +0200
Message-ID: <1314714064-29101-9-git-send-email-peppe.cavallaro@st.com>
References: <1314714064-29101-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:32939 "EHLO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754487Ab1H3OVy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 10:21:54 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id C51ACDB
	for <netdev@vger.kernel.org>; Tue, 30 Aug 2011 14:21:51 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 85781226C
	for <netdev@vger.kernel.org>; Tue, 30 Aug 2011 14:21:51 +0000 (GMT)
In-Reply-To: <1314714064-29101-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 Documentation/networking/stmmac.txt |   33 ++++++++++++++++++++++++++++++++-
 1 files changed, 32 insertions(+), 1 deletions(-)

diff --git a/Documentation/networking/stmmac.txt b/Documentation/networking/stmmac.txt
index 57a2410..40ec92c 100644
--- a/Documentation/networking/stmmac.txt
+++ b/Documentation/networking/stmmac.txt
@@ -235,7 +235,38 @@ reset procedure etc).
  o enh_desc.c: functions for handling enhanced descriptors
  o norm_desc.c: functions for handling normal descriptors
 
-5) TODO:
+5) Debug Information
+
+The driver exports many information i.e. internal statistics,
+debug information, MAC and DMA registers etc.
+
+These can be read in several ways depending on the
+type of the information actually needed.
+
+For example a user can be use the ethtool support
+to get statistics: e.g. using: ethtool -S ethX
+(that shows the Management counters (MMC) if supported)
+or sees the MAC/DMA registers: e.g. using: ethtool -d ethX
+
+Compiling the Kernel with CONFIG_DEBUG_FS and enabling the
+STMMAC_DEBUG_FS option the driver will export the following
+debugfs entries:
+
+/sys/kernel/debug/stmmaceth/descriptors_status
+  To show the DMA TX/RX descriptor rings
+
+Developer can also use the "debug" module parameter to get
+further debug information.
+
+In the end, there are other macros (that cannot be enabled
+via menuconfig) to turn-on the RX/TX DMA debugging,
+specific MAC core debug printk etc. Others to enable the
+debug in the TX and RX processes.
+All these are only useful during the developing stage
+and should never enabled inside the code for general usage.
+In fact, these can generate an huge amount of debug messages.
+
+6) TODO:
  o XGMAC is not supported.
  o Review the timer optimisation code to use an embedded device that will be
   available in new chip generations.
-- 
1.7.4.4
