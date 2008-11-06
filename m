From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: net-next-2.6 [PATCH 0/4] dccp: Feature negotiation - conclusion of Part I (basis)
Date: Thu,  6 Nov 2008 06:40:10 +0100
Message-ID: <1225950014-6337-1-git-send-email-gerrit@erg.abdn.ac.uk>
References: <20081104.235652.27274000.davem@davemloft.net>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:47223 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750703AbYKFFk1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Nov 2008 00:40:27 -0500
In-Reply-To: <20081104.235652.27274000.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

please find via the following 4 emails the remaining patches for
the first set part of the feature-negotiation patch set.

I have checked each individually to compile cleanly.

Best regards
Gerrit


Commit summary
--------------
The set concludes the first set of the feature negotiation patches to provide
a self-contained feature negotiation API for the DCCP protocol (RFC 4340-2).

The whole set is structured into 3 main blocks - (1) basis, (2) core,
(3) integration and cleanup.

Within these blocks, this is the second set and its purpose is to conclude
the base implementation, preparing for the (15) core patches in the second set.


List of patches in this set:
----------------------------
Patch #1: Changes the existing policy to allow anytime changes as that lead
          to unpredictable results.
Patch #2: Adds registration routines. These form part of the user interface
          and are later used by the socket API to set individual preferences.
Patch #3: CCIDs are a negotiable feature. This patch adds support to query the
          supported CCIDs, so as to advertise only the locally supported ones.
Patch #4: The choice of CCID in turn creates new feature dependencies. The patch
          adds automatic tracking of such dependencies to avoid later failure.

The set is also available for viewing online, beginning at
http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=commitdiff;h=822761d3e69a1f7f8b994d1d7efd7771351e0195


Patch stats:
------------
 Documentation/networking/dccp.txt |    4 
 include/linux/dccp.h              |    1 
 net/dccp/ccid.c                   |   48 +++++
 net/dccp/ccid.h                   |    5 
 net/dccp/ccids/ccid2.c            |    6 
 net/dccp/dccp.h                   |    1 
 net/dccp/feat.c                   |  306 +++++++++++++++++++++++++++++++++-----
 net/dccp/feat.h                   |   25 ++-
 net/dccp/options.c                |   18 --
 net/dccp/output.c                 |    4 
 net/dccp/proto.c                  |    7 
 net/dccp/timer.c                  |   12 -
 12 files changed, 368 insertions(+), 69 deletions(-)
