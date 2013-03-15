From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCHv3 iproute2 0/3] Add support for bridge port link information
Date: Fri, 15 Mar 2013 13:01:06 -0400
Message-ID: <1363366869-27778-1-git-send-email-vyasevic@redhat.com>
Cc: shemminger@vyatta.com, john.r.fastabend@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23532 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755064Ab3CORBM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Mar 2013 13:01:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bridge ports provide unique link information about the properties and flags of
the port.  This patch set allows bridge utility to configure and disaplay
this information.

Please take a look at the man page text and let me know if you have anything
to add.

Since v2:
 - Remove master and self flags from brind link man page.  They were removed
   from the patch and made implicit since the only self command we support is
   hwmode right now.

Since v1:
 - Change the link output to match link command line options as suggested by
   Stephen.
 - Add man page text.
 - Add root_block attribute.

Vlad Yasevich (3):
  bridge: Add support for setting bridge port attributes
  bridge: Add support for printing bridge port attributes
  man: Add documentation for the bridge link operation.

 bridge/br_common.h   |    1 +
 bridge/bridge.c      |    3 +-
 bridge/link.c        |  294 ++++++++++++++++++++++++++++++++++++++++++++++++-
 include/libnetlink.h |    2 +
 lib/libnetlink.c     |   13 ++-
 man/man8/bridge.8    |  136 +++++++++++++++++++++---
 6 files changed, 427 insertions(+), 22 deletions(-)

-- 
1.7.7.6
