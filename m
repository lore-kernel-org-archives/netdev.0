From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/2][pull request] Intel Wired LAN Driver Updates 2014-09-06
Date: Sat,  6 Sep 2014 05:34:00 -0700
Message-ID: <1410006842-26517-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:35742 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750863AbaIFMeF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Sep 2014 08:34:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000 and igb.

Krzysztof provides a patch to cleanup the coding style in e1000 to quiet
checkpatch.pl warnings.

Todd adds two boolean flags to igb to allow for changes in the
advertised EEE speeds from ethtool.

The following are changes since commit cfecec56ae7c7c40f23fbdac04acee027ca3bd66:
  mlx4: only pull headers into skb head
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Krzysztof Majzerowicz-Jaszcz (1):
  e1000: e1000_ethertool.c coding style fixes

Todd Fujinaka (1):
  igb: add flags to set eee advertisement mode

 drivers/net/ethernet/intel/e1000/e1000_ethtool.c | 155 ++++++++++++-----------
 drivers/net/ethernet/intel/igb/e1000_82575.c     |  31 ++++-
 drivers/net/ethernet/intel/igb/e1000_82575.h     |   4 +-
 drivers/net/ethernet/intel/igb/igb_ethtool.c     |  24 +++-
 drivers/net/ethernet/intel/igb/igb_main.c        |   8 +-
 5 files changed, 128 insertions(+), 94 deletions(-)

-- 
1.9.3
