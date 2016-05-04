From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [ethtool 0/3][pull request] Intel Wired LAN Driver Updates 2016-05-03
Date: Wed,  4 May 2016 09:44:50 -0700
Message-ID: <1462380293-4132-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:58281 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753237AbcEDQo4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2016 12:44:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe in ethtool.

Preethi adds missing device IDs and mac_type definitions, also updated
the display registers for x550, x550em_x/a.  Cleaned up the format string
storage by taking advantage of "for" loops.

The following are changes since commit deb1c6613ec14fd828d321e38c7bea45fe559bd5:
  Release version 4.5.
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/ethtool master

Preethi Banala (3):
  ethtool/ixgbe: Add device ID and mac_type definitions
  ethtool/ixgbe: Correct offsets and support x550, x550em_x, x550em_a
  ethtool/ixgbe: Reduce format string storage

 ixgbe.c | 173 +++++++++++++++++++++++++++++++++++-----------------------------
 1 file changed, 95 insertions(+), 78 deletions(-)

-- 
2.5.5
