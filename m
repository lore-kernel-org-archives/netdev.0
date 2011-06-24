From: greearb@candelatech.com
Subject: [RFC v2 0/2] Enable RX-FCS in e100
Date: Fri, 24 Jun 2011 12:06:09 -0700
Message-ID: <1308942371-12748-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:53298 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754881Ab1FXTGQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 15:06:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This is on top of Miroslaw's patches.  No new patches
are required to ethtool.

This is for RFC only until his patches go in.

Ben Greear (2):
  net:  Support RXFCS feature flag.
  e100:  Support RXFCS feature flag.

 drivers/net/e100.c              |   15 ++++++++++++---
 include/linux/netdev_features.h |    2 ++
 net/core/ethtool.c              |    1 +
 3 files changed, 15 insertions(+), 3 deletions(-)

-- 
1.7.3.4

