From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 1/5] stmmac: review driver documentation
Date: Mon,  8 Apr 2013 14:09:59 +0200
Message-ID: <1365423003-23959-2-git-send-email-peppe.cavallaro@st.com>
References: <1365423003-23959-1-git-send-email-peppe.cavallaro@st.com>
Cc: eric.dumazet@gmail.com, bhutchings@solarflare.com,
	shiraz.hashim@st.com, Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:46613 "EHLO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935294Ab3DHMKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 08:10:20 -0400
In-Reply-To: <1365423003-23959-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch reviews the driver documentation file;
for example, there were some new fields (in the driver
module parameter section) and the ptp files were
not documented.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 Documentation/networking/stmmac.txt |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/Documentation/networking/stmmac.txt b/Documentation/networking/stmmac.txt
index 8efe0b3..654d2e5 100644
--- a/Documentation/networking/stmmac.txt
+++ b/Documentation/networking/stmmac.txt
@@ -1,6 +1,6 @@
        STMicroelectronics 10/100/1000 Synopsys Ethernet driver
 
-Copyright (C) 2007-2010  STMicroelectronics Ltd
+Copyright (C) 2007-2013  STMicroelectronics Ltd
 Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
 
 This is the driver for the MAC 10/100/1000 on-chip Ethernet controllers
@@ -10,7 +10,7 @@ Currently this network device driver is for all STM embedded MAC/GMAC
 (i.e. 7xxx/5xxx SoCs), SPEAr (arm), Loongson1B (mips) and XLINX XC2V3000
 FF1152AMT0221 D1215994A VIRTEX FPGA board.
 
-DWC Ether MAC 10/100/1000 Universal version 3.60a (and older) and DWC Ether
+DWC Ether MAC 10/100/1000 Universal version 3.70a (and older) and DWC Ether
 MAC 10/100 Universal version 4.0 have been used for developing this driver.
 
 This driver supports both the platform bus and PCI.
@@ -32,6 +32,8 @@ The kernel configuration option is STMMAC_ETH:
 	watchdog: transmit timeout (in milliseconds);
 	flow_ctrl: Flow control ability [on/off];
 	pause: Flow Control Pause Time;
+	eee_timer: tx EEE timer;
+	chain_mode: select chain mode instead of ring.
 
 3) Command line options
 Driver parameters can be also passed in command line by using:
@@ -164,12 +166,12 @@ Where:
  o bus_setup: perform HW setup of the bus. For example, on some ST platforms
 	     this field is used to configure the AMBA  bridge to generate more
 	     efficient STBus traffic.
- o init/exit: callbacks used for calling a custom initialisation;
+ o init/exit: callbacks used for calling a custom initialization;
 	     this is sometime necessary on some platforms (e.g. ST boxes)
 	     where the HW needs to have set some PIO lines or system cfg
 	     registers.
  o custom_cfg/custom_data: this is a custom configuration that can be passed
-			   while initialising the resources.
+			   while initializing the resources.
  o bsp_priv: another private poiter.
 
 For MDIO bus The we have:
@@ -273,6 +275,8 @@ reset procedure etc).
  o norm_desc.c: functions for handling normal descriptors;
  o chain_mode.c/ring_mode.c:: functions to manage RING/CHAINED modes;
  o mmc_core.c/mmc.h: Management MAC Counters;
+ o stmmac_hwtstamp.c: HW timestamp support for PTP
+ o stmmac_ptp.c: PTP 1588 clock
 
 5) Debug Information
 
-- 
1.7.4.4
