From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/4][pull request] Intel Wired LAN Driver Updates
Date: Tue,  4 Sep 2012 23:25:46 -0700
Message-ID: <1346826350-27733-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:15545 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750957Ab2IEG0A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Sep 2012 02:26:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to igb and ixgbe.

The following are changes since commit 600e177920df936d03b807780ca92c662af98990:
  net: Providing protocol type via system.sockprotoname xattr of /proc/PID/fd entries
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Akeem G. Abodunrin (1):
  igb: Supported and Advertised Pause Frame

Carolyn Wyborny (1):
  igb: Add loopback test support for i210

Eliezer Tamir (1):
  ixgbe: remove old init remnant

Eric Dumazet (1):
  igb: reduce Rx header size

 drivers/net/ethernet/intel/igb/igb.h          |  4 +-
 drivers/net/ethernet/intel/igb/igb_ethtool.c  | 72 +++++++++++++--------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  5 --
 3 files changed, 36 insertions(+), 45 deletions(-)

-- 
1.7.11.4
