From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 0/6] stmmac: fix EEE and chained mode
Date: Wed, 26 Feb 2014 09:01:01 +0100
Message-ID: <1393401667-6452-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:33233 "EHLO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750772AbaBZICg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 03:02:36 -0500
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 813D01CD
	for <netdev@vger.kernel.org>; Wed, 26 Feb 2014 08:02:32 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas22.st.com [10.75.90.92])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 3A59AA98B
	for <netdev@vger.kernel.org>; Wed, 26 Feb 2014 08:02:32 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These are some patches to fix some problem in the driver.
For example the EEE that needs to be disabled if not supported
and the chain mode that is broken and the kernel panics.

Also there are two patches to fix some minor issues in the STi glue-logic.

Giuseppe Cavallaro (6):
  stmmac: disable at run-time the EEE if not supported
  stmmac: fix and better tune the default buffer sizes
  stmmac: dwmac-sti: fix broken STiD127 compatibility
  stmmac: dwmac-sti: remove useless tx_retime_srcs
  stmmac: remove useless check in the stmmac_tx_clean
  stmmac: fix chained mode

 drivers/net/ethernet/stmicro/stmmac/chain_mode.c   |    2 +-
 drivers/net/ethernet/stmicro/stmmac/common.h       |   20 +---
 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c    |    8 --
 drivers/net/ethernet/stmicro/stmmac/ring_mode.c    |    9 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  104 ++++++++++---------
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    2 +-
 6 files changed, 67 insertions(+), 78 deletions(-)

-- 
1.7.4.4
