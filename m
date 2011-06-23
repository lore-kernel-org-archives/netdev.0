From: greearb@candelatech.com
Subject: [PATCH 0/2] Enable RXFCS as a feature.
Date: Thu, 23 Jun 2011 16:13:37 -0700
Message-ID: <1308870819-15938-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:37357 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934540Ab1FWXNn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2011 19:13:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

These patches are on top of the features work that
Michal Miroslaw posted recently.

A small patch to ethtool is needed as well.

These are just for comment until his patches go in.

Ben Greear (2):
  net:  Support RXFCS feature flag.
  e100:  Support RXFCS feature flag.

 drivers/net/e100.c              |   15 ++++++++++++---
 include/linux/ethtool.h         |    1 +
 include/linux/netdev_features.h |    2 ++
 net/core/ethtool.c              |   10 ++++++++--
 4 files changed, 23 insertions(+), 5 deletions(-)

-- 
1.7.3.4

