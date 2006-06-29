From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 0/3] TIPC updates (resend)
Date: Thu, 29 Jun 2006 17:34:47 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0606291719220.1695@ulinpc219.uab.ericsson.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, per.liden@ericsson.com,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw3.ericsson.se ([193.180.251.60]:13017 "EHLO
	mailgw3.ericsson.se") by vger.kernel.org with ESMTP
	id S1750796AbWF2Pex (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 11:34:53 -0400
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a resend of this patch set. A problem was found with the direct 
inspection of bundle buffer tailroom. It did not account for the 
possiblity of unrequested tailroom added by skb_alloc(), thereby allowing 
a bundle to be created that exceeds the current link MTU. An additional 
check now ensures that bundling works correctly no matter if the bundle 
buffer is smaller, larger, or equal to the link MTU.

Please pull from:

 git://tipc.cslab.ericsson.net/pub/git/tipc.git

Summary:

 net/tipc/core.c |    3 ++-
 net/tipc/core.h |    5 ++++-
 net/tipc/link.c |   13 ++++++++-----
 net/tipc/node.c |   26 +++++++++++++++++---------
 net/tipc/zone.h |    4 ++--
 5 files changed, 33 insertions(+), 18 deletions(-)

Allan Stephens:
      [TIPC] Fixed skb_under_panic caused by tipc_link_bundle_buf
      [TIPC] Improve response to requests for node/link information
      [TIPC] Initial activation message now includes TIPC version number

/Per
