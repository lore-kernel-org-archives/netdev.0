From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 0/4 (net.git)] stmmac update Feb_2012
Date: Tue, 14 Feb 2012 08:11:44 +0100
Message-ID: <1329203508-19612-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:36421 "EHLO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754806Ab2BNHMG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 02:12:06 -0500
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 77C6BA7
	for <netdev@vger.kernel.org>; Tue, 14 Feb 2012 07:12:02 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 1205317D5
	for <netdev@vger.kernel.org>; Tue, 14 Feb 2012 07:12:02 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

This updates the stmmac adding some patches already reviewed in this mailing list by D. Miller.
I've rebased these patches against this recent patch:
[PATCH] [trivial] stmicro: Fix typo in stmmac_pci.c and stmmac_platform.c
applied by Maintainer (to avoid conflicts in the plt and pci files).

Let me know if all is ok.

Best Regards
Peppe

Francesco Virlinzi (1):
  stmmac: request_irq when use an ext wake irq line (v2)

Giuseppe Cavallaro (3):
  stmmac: do not discard frame on dribbling bit assert
  stmmac: move hw init in the probe
  stmmac: update the driver version to Feb 2012

 drivers/net/ethernet/stmicro/stmmac/common.h       |    1 +
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c     |    2 +-
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c    |    2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    5 +-
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |    7 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  205 ++++++++++----------
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c   |    4 +-
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   21 +--
 8 files changed, 129 insertions(+), 118 deletions(-)

-- 
1.7.4.4
