From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH ethtool 0/3] Add rx_copybreak support
Date: Sat, 13 Sep 2014 15:26:44 +0530
Message-ID: <1410602207-9084-1-git-send-email-_govind@gmx.com>
Cc: netdev@vger.kernel.org, ssujith@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.200]:62719 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751908AbaIMJ5c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2014 05:57:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series add support for setting/getting driver's rx_copybreak value.
rx_copybreak is set/get using new ethtool tunable interface.

This was added to net-next in
commit: f0db9b073415848709dd59a6394969882f517da9

	ethtool: Add generic options for tunables

Govindarajulu Varadarajan (3):
  ethtool-copy.h: sync with net-next-3.17.0-rc4
  ethtool: Add rx_copybreak support
  ethtool.8.in: Add man page for rx_copybreak

 ethtool-copy.h | 506 ++++++++++++++++++++++++++++++++++++++++++++-------------
 ethtool.8.in   |  18 ++
 ethtool.c      |  54 ++++++
 3 files changed, 463 insertions(+), 115 deletions(-)

-- 
2.1.0
