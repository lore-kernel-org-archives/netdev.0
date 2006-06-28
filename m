From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 0/3] TIPC updates
Date: Wed, 28 Jun 2006 14:07:01 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0606281358100.6341@ulinpc219.uab.ericsson.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, per.liden@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:42126 "EHLO
	mailgw4.ericsson.se") by vger.kernel.org with ESMTP
	id S1423300AbWF1MHF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 08:07:05 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch set includes three fixes/cleanups. Please see each individual 
patch for further description.

Please pull from:

 git://tipc.cslab.ericsson.net/pub/git/tipc.git

 (rebased on linux/kernel/git/davem/net-2.6.git)

Summary:

 net/tipc/core.c |    3 ++-
 net/tipc/link.c |   11 ++++++-----
 net/tipc/node.c |   26 +++++++++++++++++---------
 net/tipc/zone.h |    4 ++--
 4 files changed, 27 insertions(+), 17 deletions(-)

Allan Stephens:
      [TIPC] Fixed skb_under_panic caused by tipc_link_bundle_buf
      [TIPC] Improve response to requests for node/link information
      [TIPC] Initial activation message now includes TIPC version number

/Per
