From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 0/2][BUG-FIX] dccp: two bug-fixes
Date: Sat,  3 Mar 2012 09:33:51 -0700
Message-ID: <1330792433-15415-1-git-send-email-gerrit@erg.abdn.ac.uk>
References: <test_tree_patch_set_update_2012-03-03>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:49852 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753273Ab2CCQpc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Mar 2012 11:45:32 -0500
In-Reply-To: <test_tree_patch_set_update_2012-03-03>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

please find attached two bug fix patches for DCCP.  

 Patch #1: removes a BUG_ON which got triggered under normal operational conditions,
           found that it is not even necessary, hence replaced;
 Patch #2: fixes sequence number handling during initial connection setup, ensuring
           connection establishment even if one or more initial Request(s) get lost.

The patches are also available applied on top of today's net-next, at

	git://eden-feed.erg.abdn.ac.uk/net-next  [subtree 'dccp']

All patches have been tested and compile independently.
---	   
 include/linux/dccp.h   |    8 ++++++--
 net/dccp/ccids/ccid3.c |    3 +--
 net/dccp/ipv4.c        |    8 +++++---
 net/dccp/ipv6.c        |    8 +++++---
 net/dccp/minisocks.c   |   18 +++++++++++-------
 net/dccp/output.c      |   10 +++++-----
 6 files changed, 33 insertions(+), 22 deletions(-)
