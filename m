From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH 0/2] net: qcom/emac: fixes for pause frame floods
Date: Tue,  1 Aug 2017 16:37:38 -0500
Message-ID: <1501623460-3575-1-git-send-email-timur@codeaurora.org>
Cc: timur@codeaurora.org
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:40414 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752366AbdHAVhr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 17:37:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first patch is for 4.13.  It's changes the default behavior of the
EMAC driver so that it doesn't send pause frames unless the user 
enables them.

The second patch is for 4.14, but it can be applied to 4.13 if you
want.  It adds the ability for the user to enable a special "single
pause frame" mode that could be useful in some situations.

Timur Tabi (2):
  [for 4.13] net: qcom/emac: disable flow control autonegotiation by
    default
  net: qcom/emac: add software control for pause frame mode

 drivers/net/ethernet/qualcomm/emac/emac-ethtool.c | 30 +++++++++++++++++++++++
 drivers/net/ethernet/qualcomm/emac/emac-mac.c     | 22 +++++++++++++++++
 drivers/net/ethernet/qualcomm/emac/emac.c         | 12 +++++++--
 drivers/net/ethernet/qualcomm/emac/emac.h         |  3 +++
 4 files changed, 65 insertions(+), 2 deletions(-)

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
