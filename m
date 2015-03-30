From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: [PATCH net-next v3 0/2]: ixgbe: Add the appropriate ethtool ops to query RSS indirection table and key
Date: Mon, 30 Mar 2015 21:18:56 +0300
Message-ID: <1427739538-1038-1-git-send-email-vladz@cloudius-systems.com>
Cc: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
	avi@cloudius-systems.com, gleb@cloudius-systems.com,
	Vlad Zolotarov <vladz@cloudius-systems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:36690 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753109AbbC3STE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 14:19:04 -0400
Received: by wibg7 with SMTP id g7so112598386wib.1
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 11:19:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the ethtool ops to VF driver to allow querying the RSS indirection table
and RSS Random Key.

This series refactors the RSS configuration code to store the current contents of
RSS indirection table and Hash Key in the "adapter" struct so that we won't need
to access registers every time this info is queried.

New in v3:
   - Fix the byte ordering in RETA storing.

New in v2:
   - Some styling fixes.
   - Moved macros definitions from ixgbe_type.h to ixgbe.h.

Vlad Zolotarov (2):
  ixgbe: Refactor the RSS configuration code.
  ixgbe: Add the appropriate ethtool ops to query RSS indirection table
    and key

 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |  10 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |  42 +++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 147 ++++++++++++++++-------
 3 files changed, 155 insertions(+), 44 deletions(-)

-- 
2.1.0
