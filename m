From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 0/4] stmmac fixes for net.git.
Date: Mon,  4 Jun 2012 17:37:46 +0200
Message-ID: <1338824270-9222-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:54621 "EHLO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760817Ab2FDPiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 11:38:18 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 66C75115
	for <netdev@vger.kernel.org>; Mon,  4 Jun 2012 15:38:01 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id BE93A463A
	for <netdev@vger.kernel.org>; Mon,  4 Jun 2012 15:38:01 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set of patches fixes some problem in the driver included
in net.git.
A patch fixes a problem in the driver when built as dynamic
module. Another one fixes some useless initialisations in the
rx/tx processes.

Giuseppe Cavallaro (4):
  stmmac: remove two useless initialisation
  stmmac: fix driver's doc when run kernel-doc script
  stmmac: update driver's doc
  stmmac: fix driver Kconfig when built as module

 Documentation/networking/stmmac.txt                |   44 +++++++++++--------
 drivers/net/ethernet/stmicro/stmmac/Kconfig        |    5 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    3 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   35 ++++++++++++++--
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c   |   29 +------------
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    4 +-
 6 files changed, 62 insertions(+), 58 deletions(-)

-- 
1.7.4.4
