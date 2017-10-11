From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH 0/4] net: qcom/emac: various minor fixes
Date: Wed, 11 Oct 2017 14:52:22 -0500
Message-ID: <1507751546-10265-1-git-send-email-timur@codeaurora.org>
Cc: timur@codeaurora.org
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:37542 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752417AbdJKTwb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 15:52:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A set of patches for 4.15 that clean up some code, apply minors fixes,
and so on.  Some of the code also prepares the driver for a future 
version of the EMAC controller.

Timur Tabi (4):
  net: qcom/emac: specify the correct DMA mask
  net: qcom/emac: remove unused address arrays
  net: qcom/emac: enforce DMA address restrictions
  net: qcom/emac: clean up some TX/RX error messages

 drivers/net/ethernet/qualcomm/emac/emac-mac.c   | 55 ++++++++++++-------------
 drivers/net/ethernet/qualcomm/emac/emac-sgmii.c | 15 +++----
 drivers/net/ethernet/qualcomm/emac/emac.c       | 25 ++++-------
 3 files changed, 41 insertions(+), 54 deletions(-)

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
