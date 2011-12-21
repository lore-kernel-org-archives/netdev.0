From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 2/2 (net.git)] stmmac: update the driver's documentation (Dec-2011)
Date: Wed, 21 Dec 2011 14:58:18 +0100
Message-ID: <1324475900-1470-2-git-send-email-peppe.cavallaro@st.com>
References: <4EF1E582.5050300@st.com>
 <1324475900-1470-1-git-send-email-peppe.cavallaro@st.com>
Cc: davem@davemloft.net, rayagond@vayavyalabs.com,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:44575 "EHLO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751928Ab1LUN6u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 08:58:50 -0500
In-Reply-To: <1324475900-1470-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 Documentation/networking/stmmac.txt |   16 +++++++++-------
 1 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/Documentation/networking/stmmac.txt b/Documentation/networking/stmmac.txt
index 8d67980..d0aeead 100644
--- a/Documentation/networking/stmmac.txt
+++ b/Documentation/networking/stmmac.txt
@@ -4,14 +4,16 @@ Copyright (C) 2007-2010  STMicroelectronics Ltd
 Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
 
 This is the driver for the MAC 10/100/1000 on-chip Ethernet controllers
-(Synopsys IP blocks); it has been fully tested on STLinux platforms.
+(Synopsys IP blocks).
 
 Currently this network device driver is for all STM embedded MAC/GMAC
-(i.e. 7xxx/5xxx SoCs) and it's known working on other platforms i.e. ARM SPEAr.
+(i.e. 7xxx/5xxx SoCs), SPEAr (arm), Loongson1B (mips) and XLINX XC2V3000
+FF1152AMT0221 D1215994A VIRTEX FPGA board.
 
-DWC Ether MAC 10/100/1000 Universal version 3.41a and DWC Ether MAC 10/100
-Universal version 4.0 have been used for developing the first code
-implementation.
+DWC Ether MAC 10/100/1000 Universal version 3.60a (and older) and DWC Ether MAC 10/100
+Universal version 4.0 have been used for developing this driver.
+
+This driver supports both the platform bus and PCI.
 
 Please, for more information also visit: www.stlinux.com
 
@@ -277,5 +279,5 @@ In fact, these can generate an huge amount of debug messages.
 
 6) TODO:
  o XGMAC is not supported.
- o Review the timer optimisation code to use an embedded device that will be
-  available in new chip generations.
+ o Add the EEE - Energy Efficient Ethernet
+ o Add the PTP - precision time protocol
-- 
1.7.4.4
