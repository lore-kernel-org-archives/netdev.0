From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH 0/2] net: qcom/emac: add the last ethtool functions
Date: Wed,  8 Feb 2017 15:49:26 -0600
Message-ID: <1486590568-31398-1-git-send-email-timur@codeaurora.org>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:32966 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750972AbdBHVtc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 16:49:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two patches implement the remaining two ethtool functions that
are of interest to the Qualcomm EMAC driver.  These are the last 
patches that will be submitted for the 4.11 merge window.

Timur Tabi (2):
  net: qcom/emac: add ethtool support for reading hardware registers
  net: qcom/emac: add ethtool support for setting ring parameters

 drivers/net/ethernet/qualcomm/emac/emac-ethtool.c |  64 +++++++++++++
 drivers/net/ethernet/qualcomm/emac/emac-mac.c     |  52 -----------
 drivers/net/ethernet/qualcomm/emac/emac.h         | 108 ++++++++++++++++------
 3 files changed, 143 insertions(+), 81 deletions(-)

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
