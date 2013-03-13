From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH iproute2 0/2] Add support for bridge port link information
Date: Wed, 13 Mar 2013 16:36:32 -0400
Message-ID: <1363206994-18599-1-git-send-email-vyasevic@redhat.com>
Cc: shemminger@vyatta.com, john.r.fastabend@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17661 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933244Ab3CMUgk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Mar 2013 16:36:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bridge ports provide unique link information about the properties and flags of
the port.  This patch set allows bridge utility to configure and disaplay
this information.

Vlad Yasevich (2):
  bridge: Add support for setting bridge port attributes
  bridge: Add support for printing bridge port attributes

 bridge/br_common.h   |    1 +
 bridge/bridge.c      |    3 +-
 bridge/link.c        |  289 ++++++++++++++++++++++++++++++++++++++++++++++++-
 include/libnetlink.h |    2 +
 lib/libnetlink.c     |   13 ++-
 5 files changed, 299 insertions(+), 9 deletions(-)

-- 
1.7.7.6
