From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: net-next-2.6 [PATCH 0/7] dccp: Feature negotiation - Part III (integration)
Date: Sat,  6 Dec 2008 17:40:50 +0100
Message-ID: <1228581657-6724-1-git-send-email-gerrit@erg.abdn.ac.uk>
References: <1228051376-8174-1-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:43894 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751211AbYLFQlI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Dec 2008 11:41:08 -0500
In-Reply-To: <1228051376-8174-1-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

please find enclosed the penultimate set, the first out of two in the last
block, of the feature-negotiation patch set submission.
I have checked these to compile individually. 

Gerrit


Commit summary:
---------------
This is a continuation of an ongoing submission to provide feature/capability
negotiation for DCCP endpoints (RFC 4340 - 4342, 5348).

The whole set is structured into 3 main blocks - (1) basis, (2) core, (3)
integration and cleanup.

This set is the first out of two in block (3) and  removes the old, now unused,
parts of the older interface and begins the integration of the new interface 
that formed part (2) of this submission.

The second and last part of block (3) deals with the initialization of 
feature-negotiation state.


List of patches in this set:
----------------------------
Patch #1: Integration of dynamic negotiation, part I (socket setup).
Patch #2: Integration of dynamic negotiation, part II (server side).
Patch #3: Integration of dynamic negotiation, part III (client side).
Patch #4: Cleans up the older infrastructure.
Patch #5: Removes obsolete parts of the old CCID interface.
Patch #6: Removes manual intervention on NDP count (now automatic).
Patch #7: Removes Ack Vector sysctl (handled automatically now).

The set is also available for viewing online, beginning at
http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=commitdiff;h=c47390a8b5faaec4a41337714b2d80c85fc6ba26


Patch stats:
------------
 Documentation/networking/dccp.txt |   11 
 include/linux/dccp.h              |   10 
 net/dccp/ccid.c                   |   14 -
 net/dccp/ccid.h                   |    5 
 net/dccp/dccp.h                   |    4 
 net/dccp/diag.c                   |    2 
 net/dccp/feat.c                   |  519 --------------------------------------
 net/dccp/feat.h                   |   12 
 net/dccp/input.c                  |   42 ++-
 net/dccp/minisocks.c              |   46 ---
 net/dccp/options.c                |   11 
 net/dccp/proto.c                  |   49 ---
 net/dccp/sysctl.c                 |   14 -
 13 files changed, 70 insertions(+), 669 deletions(-)
