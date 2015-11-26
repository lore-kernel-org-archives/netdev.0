From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 0/5] Spare stmmac fixes
Date: Thu, 26 Nov 2015 08:35:40 +0100
Message-ID: <1448523345-832-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:56762 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751423AbbKZH2B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 02:28:01 -0500
Received: from pps.filterd (m0046668.ppops.net [127.0.0.1])
	by mx07-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id tAQ7NXnD017299
	for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 08:28:00 +0100
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx07-00178001.pphosted.com with ESMTP id 1ycpmrt7kg-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 08:28:00 +0100
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 9A1FE3D
	for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 07:27:25 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas24.st.com [10.75.90.94])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 7F0D3141E
	for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 07:27:57 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These are some fixes for the stmmac d.d. tested on STi platforms.
They are for some part of the PM, STi glue and rx path when test
Jumbo.

Giuseppe Cavallaro (5):
  stmmac: fix a filter problem after resuming.
  stmmac: fix csr clock divisor for 300MHz
  stmmac: dwmac-sti: fix st,tx-retime-src check
  stmmac: fix PHY reset during resume
  stmmac: fix oversized frame reception

 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c   |   13 +++++----
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    9 ++++++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c |   28 +++++++++-----------
 3 files changed, 28 insertions(+), 22 deletions(-)

-- 
1.7.4.4
