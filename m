From: Phil Reid <preid@electromag.com.au>
Subject: [PATCH 0/1] net: stmmac: socfgpa: Ensure emac bit set in System Manger for PTP
Date: Thu,  7 Apr 2016 15:55:34 +0800
Message-ID: <1460015735-8946-1-git-send-email-preid@electromag.com.au>
Cc: Phil Reid <preid@electromag.com.au>
To: peppe.cavallaro@st.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 203-59-230-133.perm.iinet.net.au ([203.59.230.133]:53496 "EHLO
	preid-centos7.electromag.com.au" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752760AbcDGIEw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 04:04:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable PTP FPGA clock, pps and ext trig connections to stmmac.
Note: This hardware configuration is not offically support by Altera.


Phil Reid (1):
  net: stmmac: socfgpa: Ensure emac bit set in System Manger for PTP

 drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

-- 
1.8.3.1
