From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: net-next-2.6 [PATCH 0/5] dccp: Feature negotiation - begin of Part II (core)
Date: Sat, 15 Nov 2008 13:11:14 +0100
Message-ID: <1226751079-15019-1-git-send-email-gerrit@erg.abdn.ac.uk>
References: <20081112063643.GB6405@gerrit.erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:42066 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754872AbYKOML1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Nov 2008 07:11:27 -0500
In-Reply-To: <20081112063643.GB6405@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

I would like to continue with the patches in the Core set, the second
out of three blocks. If the time of submission is inconvenient, please
let me know, I will then resubmit later.

Patches have been compile-tested with sparse checking enabled.

Gerrit


Commit summary:
---------------
The set begins the second set (out of three) of the feature negotiation patches,
to provide a self-contained feature negotiation API for the DCCP protocol.

The whole set is structured into 3 main blocks - (1) basis, (2) core,
(3) integration and cleanup.

Within these blocks, this set introduces the first parts of a new API to 
communicate feature-negotiation changes via socket options.


List of patches in this set:
----------------------------
Patch #1: Provides a mechanism to resolve CCID-dependent features. Since
          CCIDs are a server-priority feature, this is done by the server.
Patch #2: Deprecates old featneg API, as it was dangerous/clumsy.
Patch #3: Support to negotiate checksum-coverage values (as in UDP-Lite).
Patch #4: Deprecates Ack Ratio sysctl, to enable automatic updating.
Patch #5: Tidies up the setsockopt interface for new additions.

The set is also available for viewing online, beginning at
http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=commitdiff;h=1a2c162f1f3fee8965ef4ea3f509cd5a88be6c4f


Patch stats:
------------
 Documentation/networking/dccp.txt |    3 
 include/linux/dccp.h              |   13 ---
 net/dccp/dccp.h                   |    2 
 net/dccp/feat.c                   |  109 ++++++++++++++++++--------------
 net/dccp/feat.h                   |    5 -
 net/dccp/minisocks.c              |    1 
 net/dccp/options.c                |    1 
 net/dccp/output.c                 |   13 ++-
 net/dccp/proto.c                  |  129 +++++++++++++++-----------------------
 net/dccp/sysctl.c                 |    7 --
 10 files changed, 133 insertions(+), 150 deletions(-)
