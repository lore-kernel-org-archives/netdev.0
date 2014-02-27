From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 0/4 (v3)] stmmac fixes: EEE and chained mode
Date: Thu, 27 Feb 2014 11:35:36 +0100
Message-ID: <1393497340-8013-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:42691 "EHLO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751058AbaB0KhE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 05:37:04 -0500
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 50362EF
	for <netdev@vger.kernel.org>; Thu, 27 Feb 2014 10:37:02 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas22.st.com [10.75.90.92])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 11A6CAE7E
	for <netdev@vger.kernel.org>; Thu, 27 Feb 2014 10:37:02 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches are to fix some problem in the driver.

Mandatory changes are for EEE that needs to be disabled if not supported
and for the chain mode that is broken and the kernel panics if this mode
is enabled.

v3: removed a patch from my previous set that touched the stmmac_tx path
    that has not to be applied. Other patches for cleaning-up will be
    sent on top of net-next git repo.

Giuseppe Cavallaro (4):
  stmmac: disable at run-time the EEE if not supported
  stmmac: fix and better tune the default buffer sizes
  stmmac: dwmac-sti: fix broken STiD127 compatibility
  stmmac: fix chained mode

 drivers/net/ethernet/stmicro/stmmac/chain_mode.c   |    2 +-
 drivers/net/ethernet/stmicro/stmmac/common.h       |   20 ++---
 drivers/net/ethernet/stmicro/stmmac/ring_mode.c    |    9 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   95 +++++++++++---------
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    2 +-
 5 files changed, 64 insertions(+), 64 deletions(-)

-- 
1.7.4.4
