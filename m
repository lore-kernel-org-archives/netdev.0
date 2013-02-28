From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCHv2 iproute2 0/3] Bridge VLAN support
Date: Thu, 28 Feb 2013 15:04:03 -0500
Message-ID: <1362081846-25268-1-git-send-email-vyasevic@redhat.com>
Cc: shemminger@vyatta.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12953 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752906Ab3B1UEK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Feb 2013 15:04:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds VLAN configuration to the bridge command.  With this
series, one can specify vlans in FDB entries as well as to configure
VLAN configuration on the bridge ports.

Since v1:
 - Rebased.
 - Call rtnl_wilddump_req_filter from rtnl_wilddump_request.  Preserve always
   setting the RTEXT_FILTER_VF filter.

Vlad Yasevich (3):
  bridge: Add vlan support to fdb entries
  bridge: Add vlan configuration support
  bridge: Update bridge man pages to include vlan command

 bridge/Makefile      |    2 +-
 bridge/br_common.h   |    1 +
 bridge/bridge.c      |    3 +-
 bridge/fdb.c         |   16 ++++-
 bridge/vlan.c        |  220 ++++++++++++++++++++++++++++++++++++++++++++++++++
 include/libnetlink.h |    2 +
 lib/libnetlink.c     |    8 ++-
 man/man8/bridge.8    |   73 ++++++++++++++++-
 8 files changed, 320 insertions(+), 5 deletions(-)
 create mode 100644 bridge/vlan.c

-- 
1.7.7.6
