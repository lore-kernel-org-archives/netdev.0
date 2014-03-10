From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 0/4 (v4)] stmmac fixes: EEE and chained mode
Date: Mon, 10 Mar 2014 13:40:30 +0100
Message-ID: <1394455234-32021-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:38803 "EHLO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753399AbaCJNMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 09:12:42 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 3D943224
	for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 12:42:05 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas24.st.com [10.75.90.94])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id C00CA16534
	for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 12:42:05 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches are to fix some new problems in the STMMAC driver.

Mandatory changes are for EEE that needs to be disabled if not supported
and for the chain mode that is broken and the kernel panics if this mode
is enabled.

v3: removed a patch from my previous set that touched the stmmac_tx path
    that has not to be applied. Other patches for cleaning-up will be
    sent on top of net-next git repo.

v4: do not surround the defaul buffer selection using Koption and adopt
    a default to 1536bytes.

Giuseppe Cavallaro (4):
  stmmac: disable at run-time the EEE if not supported
  stmmac: fix and better tune the default buffer sizes
  stmmac: fix chained mode
  stmmac: dwmac-sti: fix broken STiD127 compatibility

 drivers/net/ethernet/stmicro/stmmac/chain_mode.c   |    2 +-
 drivers/net/ethernet/stmicro/stmmac/common.h       |   20 ++---
 drivers/net/ethernet/stmicro/stmmac/ring_mode.c    |    9 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   91 ++++++++++---------
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    2 +-
 5 files changed, 60 insertions(+), 64 deletions(-)

-- 
1.7.4.4
