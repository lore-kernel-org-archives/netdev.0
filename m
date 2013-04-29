From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCHv2 net-next 0/2] Add two new flags to bridge.
Date: Mon, 29 Apr 2013 13:35:43 -0400
Message-ID: <1367256945-25923-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, mst@redhat.com,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3693 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757691Ab3D2Rfw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Apr 2013 13:35:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series adds 2 new flags to bridge.  One flag allows
the user to control whether mac learning is performed on the interface
or not.  By default mac learning is on.
The other flag allows the user to control whether unicast traffic
is flooded (send without an fdb) to a given unicast port.  Default is
on.

Changes since v1:
 - Integrated suggestion from MST to not impact RTM_NEWNEIGH and to
   skip lookups when learning is disabled.

Vlad Yasevich (2):
  bridge: Add flag to control mac learning.
  bridge: Add a flag to control unicast packet flood.

 include/uapi/linux/if_link.h |    2 ++
 net/bridge/br_device.c       |    8 ++++----
 net/bridge/br_fdb.c          |   17 ++++++++++++++---
 net/bridge/br_forward.c      |   14 +++++++++-----
 net/bridge/br_if.c           |    2 +-
 net/bridge/br_input.c        |    9 ++++++---
 net/bridge/br_netlink.c      |   10 +++++++++-
 net/bridge/br_private.h      |    7 +++++--
 net/bridge/br_sysfs_if.c     |    4 ++++
 9 files changed, 54 insertions(+), 19 deletions(-)

-- 
1.7.7.6
