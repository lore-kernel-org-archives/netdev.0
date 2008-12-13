From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: net-next-2.6 [PATCH 0/5] dccp: Feature negotiation part III -- complete
Date: Sat, 13 Dec 2008 14:41:20 +0100
Message-ID: <1229175685-18716-1-git-send-email-gerrit@erg.abdn.ac.uk>
References: <20081208.011917.176472177.davem@davemloft.net>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:51144 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754680AbYLMNle (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Dec 2008 08:41:34 -0500
In-Reply-To: <20081208.011917.176472177.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

please find enclosed the last set, completing the feature negotiation
implementation. I have checked these to compile individually. 

Gerrit


Commit summary:
---------------
This is the final set out of an ongoing submission to provide feature and 
capability negotiation for DCCP endpoints (RFC 4340 - 4342, RFC 5348).

The whole set is structured into 3 main blocks - (1) basis, (2) core, (3)
integration and cleanup.

This set is the final in block (3) and implements the initialization of
feature-negotiation state. This includes picking up the global defaults
set via sysctls and to auto-load the CCID modules before announcing
available CCID modules as negotiable candidates to the peer.


List of patches in this set:
----------------------------
Patch #1: Initialisation framework for the supported features.
Patch #2: Auto-loading of CCID modules so that the modules are available
          when the negotiation is completed.
Patch #3: Adds full support for local/remote Sequence Window.
Patch #4: Initialisation and type-checking of involved sysctls.
Patch #5: A set of (useful) debugging/printing helper functions.

The set is also available for viewing online, beginning at
http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=commitdiff;h=913ef8fac15e3704794360c0862ad65a11f833ae


Patch stats:
------------
 Documentation/networking/dccp.txt |    3 
 include/linux/dccp.h              |   51 -------
 net/dccp/ccid.c                   |   39 ++++--
 net/dccp/ccid.h                   |    1 
 net/dccp/dccp.h                   |   21 +--
 net/dccp/feat.c                   |  247 ++++++++++++++++++++++++++++----------
 net/dccp/feat.h                   |   23 +--
 net/dccp/minisocks.c              |   11 -
 net/dccp/options.c                |    8 -
 net/dccp/proto.c                  |    2 
 net/dccp/sysctl.c                 |   43 ++++--
 11 files changed, 271 insertions(+), 178 deletions(-)
