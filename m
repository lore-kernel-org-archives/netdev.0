From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH 0/5] [net-next] net: qcom/emac:
Date: Fri, 27 Jan 2017 16:43:42 -0600
Message-ID: <1485557028-32510-1-git-send-email-timur@codeaurora.org>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:57208 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750745AbdA0Wzf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 17:55:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Although not related, these patches affect the same files, so they should
be applied in order.

The first patch cleans up logging of when the the phy driver is attached.

The second patch always configures the SGMII to use autonegotiation mode.

The third patch removes a redundant call to emac_mac_start().

The fourth patch removes some extraneous non-functioning WOL code.

The fifth patch adds an error handler for the SGMII block.

Timur Tabi (5):
  [net-next] net: qcom/emac: display the phy driver info after we
    connect
  [net-next] net: qcom/emac: always use autonegotiation to configure the
    SGMII link
  [net-next] net: qcom/emac: do not call emac_mac_start twice
  [net-next] net: qcom/emac: remove extraneous wake-on-lan code
  [net-next] net: qcom/emac: add an error interrupt handler for the
    sgmii

 drivers/net/ethernet/qualcomm/emac/emac-mac.c   |  24 ++--
 drivers/net/ethernet/qualcomm/emac/emac-mac.h   |   1 -
 drivers/net/ethernet/qualcomm/emac/emac-phy.c   |   3 -
 drivers/net/ethernet/qualcomm/emac/emac-sgmii.c | 175 ++++++++++++++++++------
 drivers/net/ethernet/qualcomm/emac/emac-sgmii.h |  16 ++-
 drivers/net/ethernet/qualcomm/emac/emac.c       |  10 +-
 drivers/net/ethernet/qualcomm/emac/emac.h       |   4 -
 7 files changed, 166 insertions(+), 67 deletions(-)

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
