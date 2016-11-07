From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH 0/2] net: qcom/emac: ensure that pause frames are enabled
Date: Mon,  7 Nov 2016 10:51:39 -0600
Message-ID: <1478537501-23454-1-git-send-email-timur@codeaurora.org>
To: David Miller <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>, alokc@codeaurora.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:46084 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932334AbcKGQvp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 11:51:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The qcom emac driver experiences significant packet loss (through frame
check sequence errors) if flow control is not enabled and the phy is
not configured to allow pause frames to pass through it.  Therefore, we
need to enable flow control and force the phy to pass pause frames.

Timur Tabi (2):
  net: qcom/emac: configure the external phy to allow pause frames
  [v2] net: qcom/emac: enable flow control if requested

 drivers/net/ethernet/qualcomm/emac/emac-mac.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
