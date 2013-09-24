From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/6][pull request] Intel Wired LAN Driver Updates
Date: Tue, 24 Sep 2013 02:45:04 -0700
Message-ID: <1380015910-25927-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:32601 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753414Ab3IXJpO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Sep 2013 05:45:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to igb and i40e.

Todd provides a fix for 82580 devices in igb, where the ethtool
loopback test was missing 82580 copper devices.

Jesse provides five fixes/cleanups to i40e based on feedback from
Joe Perches and the community.

The following are changes since commit 9fe34f5d920b183ec063550e0f4ec854aa373316:
  mrp: add periodictimer to allow retries when packets get lost
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Todd Fujinaka (1):
  igb: Fix ethtool loopback test for 82580 copper

Jesse Brandeburg (5):
  i40e: use common failure flow
  i40e: small clean ups from review
  i40e: convert ret to aq_ret
  i40e: better return values
  i40e: clean up coccicheck reported errors

 drivers/net/ethernet/intel/i40e/i40e_adminq.c |   7 +-
 drivers/net/ethernet/intel/i40e/i40e_common.c |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c   | 162 +++++++++++++-------------
 drivers/net/ethernet/intel/igb/igb_ethtool.c  |   3 +
 4 files changed, 89 insertions(+), 85 deletions(-)

-- 
1.8.3.1
