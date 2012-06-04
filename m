From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 0/3 (v2)] stmmac fixes for net.git
Date: Mon,  4 Jun 2012 18:32:08 +0200
Message-ID: <1338827531-10376-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:56460 "EHLO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754055Ab2FDQcS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 12:32:18 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id A72B5E3
	for <netdev@vger.kernel.org>; Mon,  4 Jun 2012 16:32:16 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 6C9C446FD
	for <netdev@vger.kernel.org>; Mon,  4 Jun 2012 16:32:16 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches fix a problem in the driver when built as dynamic
module and fix the driver's documentation.

v2: this patchset has the same patches I had sent before but
    I removed a patch that did a cleanup (now moved for net-next).

Giuseppe Cavallaro (3):
  stmmac: fix driver's doc when run kernel-doc script
  stmmac: update driver's doc
  stmmac: fix driver Kconfig when built as module

 Documentation/networking/stmmac.txt                |   44 +++++++++++--------
 drivers/net/ethernet/stmicro/stmmac/Kconfig        |    5 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    3 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   32 +++++++++++++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c   |   29 +------------
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    4 +-
 6 files changed, 61 insertions(+), 56 deletions(-)

-- 
1.7.4.4
