From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 0/4 (v2)] stmmac EEE fixes
Date: Thu, 28 Aug 2014 08:11:40 +0200
Message-ID: <1409206304-23239-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:50734 "EHLO
	mx08-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751235AbaH1GLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2014 02:11:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a subset of patches to provide some fixes for the EEE support inside the
driver.
Patches have been tested on boards EEE capable plugged on switch w/ w/o EEE
support.

Giuseppe CAVALLARO (1):
  stmmac: never check EEE in case of a switch is attached

Giuseppe Cavallaro (1):
  stmmac: fix PLS bit setting when EEE is active

nandini sharma (2):
  stmmac: fix the EEE LPI Macro definitions.
  stmmac: fix LPI TW timer value to 20.5us.

 drivers/net/ethernet/stmicro/stmmac/common.h      |   10 +++++-----
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   12 ++++++++----
 2 files changed, 13 insertions(+), 9 deletions(-)

-- 
1.7.4.4
