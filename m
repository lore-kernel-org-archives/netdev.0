From: thor.thayer@linux.intel.com
Subject: [PATCH 0/2] ethtool: stmmac: Fix DMA register dump
Date: Tue, 27 Jun 2017 16:51:13 -0500
Message-ID: <1498600275-22334-1-git-send-email-thor.thayer@linux.intel.com>
Cc: netdev@vger.kernel.org, Thor Thayer <thor.thayer@linux.intel.com>
To: linville@tuxdriver.com, peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:23551 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753710AbdF0VsS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 27 Jun 2017 17:48:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thor Thayer <thor.thayer@linux.intel.com>

The DMA register dump structure changed which requires this
change to the indexing of the DMA registers.
Also dump the DMA HW Feature Register.

Thor Thayer (2):
  ethtool: stmmac: Fix Designware ethtool register dump
  ethtool: stmmac: Add DMA HW Feature Register

 stmmac.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

-- 
2.7.4
