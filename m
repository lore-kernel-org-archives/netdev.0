From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 0/6] dccp: Feature negotiation - conclusion of Part II (core)
Date: Sun, 30 Nov 2008 14:22:50 +0100
Message-ID: <1228051376-8174-1-git-send-email-gerrit@erg.abdn.ac.uk>
References: <1226751079-15019-1-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:60014 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751490AbYK3NXI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Nov 2008 08:23:08 -0500
In-Reply-To: <1226751079-15019-1-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

please find attached the completion of the feature-negotiation
implementation, the concluding part of the second block.

The final/third block is then clerical, integrating the code 
presented in the second block; and tidying up the remaining bits.

Gerrit


Commit summary:
---------------
This is a continuation of an ongoing submission to provide feature/capability
negotiation for DCCP endpoints (RFC 4340 - 4342, 5348).

The whole set is structured into 3 main blocks - (1) basis, (2) core,
(3) integration and cleanup.

This set completes the implementation (part (2)). Online information is also at
http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/feature_negotiation/


List of patches in this set:
----------------------------
Patch #1: Continues where the previous patch set left off, by adding
          the insertion of feature-negotiation options onto the skb.
Patch #2: Completes the insertion of featneg options.
Patch #3: Logic/algorithm to actually reconcile negotiation options.
Patch #4: Receiver support to process incoming Change L/R options. 
Patch #5: Receiver support to process incoming Confirm R/L options.
Patch #6: Handlers for activating successfully negotiated features.

The set is also available for viewing online, beginning at
http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=commitdiff;h=94163f6514044c53c3761305db3c59d640c03ec1


Patch stats:
------------
 dccp.h    |    3 
 feat.c    |  635 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 feat.h    |    6 
 options.c |   72 +++----
 4 files changed, 657 insertions(+), 59 deletions(-)
