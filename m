From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: [RFC PATCH net-next 0/5]: ixgbevf: Allow querying VFs RSS indirection table and key
Date: Tue, 30 Dec 2014 18:30:30 +0200
Message-ID: <1419957035-1078-1-git-send-email-vladz@cloudius-systems.com>
Cc: gleb@cloudius-systems.com, avi@cloudius-systems.com,
	Vlad Zolotarov <vladz@cloudius-systems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:40217 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750833AbaL3Qas (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2014 11:30:48 -0500
Received: by mail-wg0-f49.google.com with SMTP id n12so20949404wgh.36
        for <netdev@vger.kernel.org>; Tue, 30 Dec 2014 08:30:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the ethtool ops to VF driver to allow querying the RSS indirection table
and RSS Random Key.

 - PF driver: Add new VF-PF channel commands.
 - VF driver: Utilize these new commands and add the corresponding
              ethtool callbacks.

Vlad Zolotarov (5):
  ixgbe: Add a RETA query command to VF-PF channel API
  ixgbevf: Add a RETA query code
  ixgbe: Add GET_RSS_KEY command to VF-PF channel commands set
  ixgbevf: Add RSS Key query code
  ixgbevf: Add the appropriate ethtool ops to query RSS indirection
    table and key

 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h      |   8 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    |  60 +++++++++++
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      |  37 +++++++
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   4 +-
 drivers/net/ethernet/intel/ixgbevf/mbx.h          |   8 ++
 drivers/net/ethernet/intel/ixgbevf/vf.c           | 125 ++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbevf/vf.h           |   2 +
 7 files changed, 243 insertions(+), 1 deletion(-)

-- 
2.1.0
