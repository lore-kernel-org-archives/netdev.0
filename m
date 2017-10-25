From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net-next 0/4] net: qualcomm: rmnet: Add 64 bit stats and GRO
Date: Tue, 24 Oct 2017 22:55:25 -0600
Message-ID: <1508907329-1077-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:43212 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750822AbdJYEzp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 00:55:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds support for 64 bit per cpu stats and GRO

Patches 1-2 are cleanups of return code and a redundant condition
Patch 3 adds support for 64 bit per cpu stats
Patch 4 adds support for GRO using GRO cells

Subash Abhinov Kasiviswanathan (4):
  net: qualcomm: rmnet: Fix the return value of rmnet_rx_handler()
  net: qualcomm: rmnet: Always assign rmnet dev in deaggregation path
  net: qualcomm: rmnet: Add support for 64 bit stats
  net: qualcomm: rmnet: Add support for GRO

 drivers/net/ethernet/qualcomm/rmnet/Kconfig        |  1 +
 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c |  6 +-
 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h | 16 ++++
 .../net/ethernet/qualcomm/rmnet/rmnet_handlers.c   | 38 ++++------
 drivers/net/ethernet/qualcomm/rmnet/rmnet_map.h    |  3 +-
 .../ethernet/qualcomm/rmnet/rmnet_map_command.c    |  4 +-
 drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c    | 85 ++++++++++++++++++++--
 drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h    |  2 +-
 8 files changed, 118 insertions(+), 37 deletions(-)

-- 
1.9.1
