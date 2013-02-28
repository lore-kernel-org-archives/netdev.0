From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH iproute 0/3] Bridge VLAN support
Date: Thu, 28 Feb 2013 11:21:51 -0500
Message-ID: <1362068514-10342-1-git-send-email-vyasevic@redhat.com>
Cc: shemminger@vyatta.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25570 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754799Ab3B1QV5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Feb 2013 11:21:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds VLAN configuration to the bridge command.  With this
series, one can specify vlans in FDB entries as well as to configure
VLAN configuration on the bridge ports.

Vlad Yasevich (3):
  bridge: Add vlan support to fdb entries
  bridge: Add vlan configuration support
  bridge: Update bridge man pages to include vlan command

 bridge/Makefile           |    2 +-
 bridge/br_common.h        |    1 +
 bridge/bridge.c           |    3 +-
 bridge/fdb.c              |   16 +++-
 bridge/vlan.c             |  220 +++++++++++++++++++++++++++++++++++++++++++++
 include/libnetlink.h      |    2 +
 include/linux/if_bridge.h |   10 ++
 include/linux/neighbour.h |    1 +
 include/linux/rtnetlink.h |    1 +
 lib/libnetlink.c          |   28 ++++++-
 man/man8/bridge.8         |   73 +++++++++++++++-
 11 files changed, 352 insertions(+), 5 deletions(-)
 create mode 100644 bridge/vlan.c

-- 
1.7.7.6
