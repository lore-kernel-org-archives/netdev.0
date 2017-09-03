From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net-next 0/6] net: qualcomm: rmnet: Fix comments on initial patchset
Date: Sat,  2 Sep 2017 23:30:40 -0600
Message-ID: <1504416646-9527-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:42546 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750795AbdICFbq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 01:31:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series fixes the comments from Dan on the first patch series.

Fixes a memory corruption which could occur if mux_id was higher than 32.
Remove the RMNET_LOCAL_LOGICAL_ENDPOINT which is no longer used.
Make a log message more useful.
Combine __rmnet_set_endpoint_config() with rmnet_set_endpoint_config().
Set the mux_id in rmnet_vnd_newlink().
Set the ingress and egress data format directly in newlink.
Implement ndo_get_iflink to find the real_dev.
Rename the real_dev_info to port to make it similar to other drivers.

The conversion of rmnet_devices to a list and hash lookup will be sent
as part of a seperate patch.

Subash Abhinov Kasiviswanathan (6):
  net: qualcomm: rmnet: Fix memory corruption if mux_id is greater than
    32
  net: qualcomm: rmnet: Remove the unused endpoint -1
  net: qualcomm: rmnet: Move the device creation log
  net: qualcomm: rmnet: Refactor the new rmnet dev creation
  net: qualcomm: rmnet: Implement ndo_get_iflink
  net: qualcomm: rmnet: Rename real_dev_info to port

 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c | 163 +++++++--------------
 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h |   9 +-
 .../net/ethernet/qualcomm/rmnet/rmnet_handlers.c   |  56 +++----
 drivers/net/ethernet/qualcomm/rmnet/rmnet_map.h    |   6 +-
 .../ethernet/qualcomm/rmnet/rmnet_map_command.c    |  13 +-
 .../net/ethernet/qualcomm/rmnet/rmnet_map_data.c   |   3 +-
 .../net/ethernet/qualcomm/rmnet/rmnet_private.h    |   1 -
 drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c    |  43 +++---
 drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h    |   6 +-
 9 files changed, 119 insertions(+), 181 deletions(-)

-- 
1.9.1
