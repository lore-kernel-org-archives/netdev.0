From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [RESEND PATCH 2/4] stmmac: add the new Header file for stmmac platform data
Date: Wed, 16 Dec 2009 08:26:43 +0100
Message-ID: <1260948405-28511-2-git-send-email-peppe.cavallaro@st.com>
References: <1260948405-28511-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:49667 "EHLO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934568AbZLPH1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2009 02:27:10 -0500
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 131B2136
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2009 07:27:02 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id D5A06772
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2009 07:27:01 +0000 (GMT)
In-Reply-To: <1260948405-28511-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 include/linux/stmmac.h |   53 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 53 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/stmmac.h

diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
new file mode 100644
index 0000000..0f7fad2
--- /dev/null
+++ b/include/linux/stmmac.h
@@ -0,0 +1,53 @@
+/*******************************************************************************
+
+  Header file for stmmac platform data
+
+  Copyright (C) 2009  STMicroelectronics Ltd
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
+*******************************************************************************/
+
+#ifndef __STMMAC_PLATFORM_DATA
+#define __STMMAC_PLATFORM_DATA __FILE__
+
+/* platfrom data for platfrom device structure's platfrom_data field */
+
+/* Private data for the STM on-board ethernet driver */
+struct plat_stmmacenet_data {
+	int bus_id;
+	int pbl;
+	int has_gmac;
+	void (*fix_mac_speed)(void *priv, unsigned int speed);
+	void (*bus_setup)(unsigned long ioaddr);
+#ifdef CONFIG_STM_DRIVERS
+	struct stm_pad_config *pad_config;
+#endif
+	void *bsp_priv;
+};
+
+struct plat_stmmacphy_data {
+	int bus_id;
+	int phy_addr;
+	unsigned int phy_mask;
+	int interface;
+	int (*phy_reset)(void *priv);
+	void *priv;
+};
+#endif
+
-- 
1.6.0.4

