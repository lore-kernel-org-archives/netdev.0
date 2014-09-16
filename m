From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next 0/3] Remove rx_copybreak module param, use ethtool to change its value
Date: Wed, 17 Sep 2014 02:21:24 +0530
Message-ID: <1410900687-9686-1-git-send-email-_govind@gmx.com>
Cc: Govindarajulu Varadarajan <_govind@gmx.com>,
	David Dillow <dave@thedillows.org>,
	Don Fry <pcnet32@frontier.com>,
	Francois Romieu <romieu@fr.zoreil.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.200]:58349 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754966AbaIPUv7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Sep 2014 16:51:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recently rx_copybreak support for ethtool has been added in
commit: f0db9b073415848709dd59a6394969882f517da9
	ethtool: Add generic options for tunables
we can use ethtool to change the rx_copybreak value.

This series removes the rx_copybreak module param and adds ethtool support for
the same.

I could only compile test the changes. I do not have the hardware.

Cc: David Dillow <dave@thedillows.org>
Cc: Don Fry <pcnet32@frontier.com>
Cc: Francois Romieu <romieu@fr.zoreil.com>

Govindarajulu Varadarajan (3):
  typhoon: use ethtool for changing rx_copybreak
  pcnet32: use ethtool for changing rx_copybreak
  sis190: use ethtool for changing rx_copybreak

 drivers/net/ethernet/3com/typhoon.c | 49 ++++++++++++++++++++++++++++++++-----
 drivers/net/ethernet/amd/pcnet32.c  | 49 +++++++++++++++++++++++++++++++++----
 drivers/net/ethernet/sis/sis190.c   | 47 ++++++++++++++++++++++++++++++++---
 3 files changed, 130 insertions(+), 15 deletions(-)

-- 
2.1.0
