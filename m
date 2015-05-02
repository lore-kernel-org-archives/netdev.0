From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH 0/2] stmac: add glue for NXP LPC18xx family
Date: Sat,  2 May 2015 18:40:40 +0200
Message-ID: <1430584842-23408-1-git-send-email-manabian@gmail.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net, arnd@arndb.de,
	linux-arm-kernel@lists.infradead.org,
	Joachim Eastwood <manabian@gmail.com>
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:35216 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751153AbbEBQlr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 May 2015 12:41:47 -0400
Received: by lbbuc2 with SMTP id uc2so81344345lbb.2
        for <netdev@vger.kernel.org>; Sat, 02 May 2015 09:41:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This small patch set adds support for using the stmmac on the NXP
LPC18xx/43xx Cortex-M3/4 MCU family and add binding documentation.

Base support for the family can be found here:
http://marc.info/?l=linux-arm-kernel&m=143016894704253&w=2

DTS changes will be posted once base support, clk support and
reset are upstream. All this has been posted on the relevant
lists and my hope is that it will make it into Linux 4.1.

Below is the boot log from the stmmac driver:
[    2.831037] stmmac - user ID: 0x11, Synopsys ID: 0x36
[    2.837085]  Ring mode enabled
[    2.840559]  DMA HW capability register supported
[    2.845457]  Enhanced/Alternate descriptors
[    2.850866]  Enabled extended descriptors
[    2.855351]  RX Checksum Offload Engine supported (type 2)
[    2.861847]  TX Checksum insertion supported
[    2.867106]  Wake-Up On Lan supported
[    2.873938]  Enable RX Mitigation via HW Watchdog Timer
[    2.923122] libphy: stmmac: probed
[    2.927750] eth0: PHY ID 0007c0f1 at 1 IRQ POLL (stmmac-0:01) active
[   94.735120]  No MAC Management Counters available
[   97.767758] stmmaceth 40010000.ethernet eth0: Link is Up - 100Mbps/Full - flow control off

Joachim Eastwood (2):
  stmac: add dwmac glue for NXP 18xx/43xx family
  doc: dt: add documentation for nxp,lpc1850-dwmac

 .../devicetree/bindings/net/nxp,lpc1850-dwmac.txt  | 20 ++++++
 drivers/net/ethernet/stmicro/stmmac/Makefile       |  3 +-
 .../net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c    | 76 ++++++++++++++++++++++
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  1 +
 .../net/ethernet/stmicro/stmmac/stmmac_platform.h  |  1 +
 5 files changed, 100 insertions(+), 1 deletion(-)
 create mode 100644 Documentation/devicetree/bindings/net/nxp,lpc1850-dwmac.txt
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c

-- 
1.8.0
