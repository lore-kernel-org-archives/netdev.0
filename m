From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: [PATCH net-next v1 0/2]: ixgbe: Add the appropriate ethtool ops to query RSS indirection table and key
Date: Thu, 26 Mar 2015 19:56:37 +0200
Message-ID: <1427392599-18184-1-git-send-email-vladz@cloudius-systems.com>
Cc: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
	avi@cloudius-systems.com, gleb@cloudius-systems.com,
	Vlad Zolotarov <vladz@cloudius-systems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:38566 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751018AbbCZR4n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 13:56:43 -0400
Received: by wibgn9 with SMTP id gn9so96701265wib.1
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 10:56:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the ethtool ops to VF driver to allow querying the RSS indirection table
and RSS Random Key.

This series refactors the RSS configuration code to store the current contents of
RSS indirection table and Hash Key in the "adapter" struct so that we won't need
to access registers every time this info is queried.

Vlad Zolotarov (2):
  ixgbe: Refactor the RSS configuration code.
  ixgbe: Add the appropriate ethtool ops to query RSS indirection table
    and key

 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |   3 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |  42 +++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 143 ++++++++++++++++-------
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h    |   7 ++
 4 files changed, 152 insertions(+), 43 deletions(-)

-- 
2.1.0
