From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 0/3 (v3)] stmmac fixes for net.git
Date: Tue,  5 Jun 2012 07:22:54 +0200
Message-ID: <1338873777-5374-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:57586 "EHLO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752335Ab2FEFXF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 01:23:05 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id CB56B93
	for <netdev@vger.kernel.org>; Tue,  5 Jun 2012 05:23:03 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 899B51C05
	for <netdev@vger.kernel.org>; Tue,  5 Jun 2012 05:23:03 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches fix a problem in the driver when built as dynamic
module and fix the driver's documentation.

v2: this patchset has the same patches I had sent before but
    I removed a patch that did a cleanup (now moved for net-next).

v3: removed wrong reviewed-by from this patch:
    "stmmac: fix driver Kconfig when built as module"

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
