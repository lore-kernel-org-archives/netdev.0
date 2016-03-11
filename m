From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCHv2 (net.git) 0/2] stmmac: MDIO fixes
Date: Fri, 11 Mar 2016 08:44:03 +0100
Message-ID: <1457682245-22746-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <gabriel.fernandez@linaro.org>, <afaerber@suse.de>,
	<fschaefer.oss@googlemail.com>, <dinh.linux@gmail.com>,
	<davem@davemloft.net>, Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:53711 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S934008AbcCKHhn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 02:37:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two patches are to fix the recent regressions raised
when test the stmmac on some platforms due to broken MDIO
management.

V2: use is_pseudo_fixed_link

Giuseppe Cavallaro (2):
  Revert "stmmac: Fix 'eth0: No PHY found' regression"
  stmmac: fix MDIO settings

 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   11 ++-------
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  |   11 +++++++++-
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   21 ++++---------------
 include/linux/stmmac.h                             |    2 -
 4 files changed, 18 insertions(+), 27 deletions(-)

-- 
1.7.4.4
