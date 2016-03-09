From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 0/2] stmmac: MDIO fixes
Date: Wed, 9 Mar 2016 10:00:05 +0100
Message-ID: <1457514007-32333-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <gabriel.fernandez@linaro.org>, <afaerber@suse.de>,
	<fschaefer.oss@googlemail.com>, <dinh.linux@gmail.com>,
	<davem@davemloft.net>, Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:52554 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752425AbcCIIxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 03:53:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two patches are to fix the recent regressions raised
when test the stmmac on some platforms.
Please I kindly ask you to give me the feedback if it actually
covers all the cases and if the stmmac runs fine on the boxes.
I have tested on my side the H410 B2120 with an embedded switch
(so using the fixed-link).

Giuseppe Cavallaro (2):
  Revert "stmmac: Fix 'eth0: No PHY found' regression"
  stmmac: fix MDIO settings

 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   11 ++-------
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  |   11 +++++++++-
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   22 +++++--------------
 include/linux/stmmac.h                             |    3 +-
 4 files changed, 20 insertions(+), 27 deletions(-)

-- 
1.7.4.4
