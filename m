From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH ethtool v2 0/3] Add copybreak support
Date: Tue,  7 Oct 2014 04:42:18 +0530
Message-ID: <1412637141-3205-1-git-send-email-_govind@gmx.com>
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	yevgenyp@mellanox.com, Govindarajulu Varadarajan <_govind@gmx.com>
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:49232 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751131AbaJFXMv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Oct 2014 19:12:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series add support for setting/getting driver's copybreak value.
copybreak is set/get using ethtool tunable interface.

This was added to net-next in
commit: f0db9b073415848709dd59a6394969882f517da9

	ethtool: Add generic options for tunables

v2:
Add support for tx_copybreak
Add 'ethtool -B eth0 rx 100 tx 256' instead of 'ethtool -B eth0 100'

Govindarajulu Varadarajan (3):
  ethtool-copy.h: Sync with net-next 3.17.0-rc7
  ethtool: Add copybreak support
  ethtool.8.in: Add man page for copybreak

 ethtool-copy.h |  29 ++++++++++
 ethtool.8.in   |  20 +++++++
 ethtool.c      | 177 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 226 insertions(+)

-- 
2.1.0
