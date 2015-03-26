From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: [PATCH net-next v2 0/2] ixgbe: Add the appropriate ethtool ops to query RSS indirection table and key
Date: Fri, 27 Mar 2015 00:44:44 +0200
Message-ID: <1427409886-20261-1-git-send-email-vladz@cloudius-systems.com>
Cc: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
	avi@cloudius-systems.com, gleb@cloudius-systems.com,
	Vlad Zolotarov <vladz@cloudius-systems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:35444 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752709AbbCZWow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 18:44:52 -0400
Received: by wibbg6 with SMTP id bg6so6661942wib.0
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 15:44:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the ethtool ops to VF driver to allow querying the RSS indirection table
and RSS Random Key.

This series refactors the RSS configuration code to store the current contents of
RSS indirection table and Hash Key in the "adapter" struct so that we won't need
to access registers every time this info is queried.

New in v2:
   - Some styling fixes.
   - Moved macros definitions from ixgbe_type.h to ixgbe.h.

Vlad Zolotarov (2):
  ixgbe: Refactor the RSS configuration code.
  ixgbe: Add the appropriate ethtool ops to query RSS indirection table
    and key

 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |  10 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |  42 +++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 142 ++++++++++++++++-------
 3 files changed, 151 insertions(+), 43 deletions(-)

-- 
2.1.0
