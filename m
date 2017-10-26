From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net-next v2 0/4] net: qualcomm: rmnet: Add 64 bit stats and GRO
Date: Thu, 26 Oct 2017 11:06:45 -0600
Message-ID: <1509037609-15444-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:45750 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932327AbdJZRHQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 13:07:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds support for 64 bit per cpu stats and GRO

Patches 1-2 are cleanups of return code and a redundant condition
Patch 3 adds support for 64 bit per cpu stats
Patch 4 adds support for GRO using GRO cells

v1->v2: Since gro_cells_init() could potentially fail, move it from device
setup to ndo_init() as mentioned by Eric.

Subash Abhinov Kasiviswanathan (4):
  net: qualcomm: rmnet: Fix the return value of rmnet_rx_handler()
  net: qualcomm: rmnet: Always assign rmnet dev in deaggregation path
  net: qualcomm: rmnet: Add support for 64 bit stats
  net: qualcomm: rmnet: Add support for GRO

 drivers/net/ethernet/qualcomm/rmnet/Kconfig        |  1 +
 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h | 16 +++++
 .../net/ethernet/qualcomm/rmnet/rmnet_handlers.c   | 38 +++++-----
 drivers/net/ethernet/qualcomm/rmnet/rmnet_map.h    |  3 +-
 .../ethernet/qualcomm/rmnet/rmnet_map_command.c    |  4 +-
 drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c    | 84 ++++++++++++++++++++--
 6 files changed, 114 insertions(+), 32 deletions(-)

-- 
1.9.1
