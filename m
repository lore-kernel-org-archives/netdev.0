From: thor.thayer@linux.intel.com
Subject: [PATCHv2 0/3] ethtool: stmmac: Fix DMA register dump
Date: Wed, 28 Jun 2017 10:13:39 -0500
Message-ID: <1498662822-12173-1-git-send-email-thor.thayer@linux.intel.com>
Cc: netdev@vger.kernel.org, thor.thayer@linux.intel.com
To: linville@tuxdriver.com, peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:15047 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751754AbdF1PLE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Jun 2017 11:11:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thor Thayer <thor.thayer@linux.intel.com>

1. The DMA register dump structure changed which requires this
change to the indexing of the DMA registers.
2. Also dump the DMA HW Feature Register.
3. V2 also adds macros for the number of registers.

Thor Thayer (3):
  ethtool: stmmac: Fix Designware ethtool register dump
  ethtool: stmmac: Add macros for number of registers
  ethtool: stmmac: Add DMA HW Feature Register

 stmmac.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

-- 
2.7.4
