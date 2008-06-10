From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [Patch 0/7] [dccp]: DCCP bug-fixes for net-2.6
Date: Tue, 10 Jun 2008 13:53:36 +0100
Message-ID: <1213102423-27486-1-git-send-email-gerrit@erg.abdn.ac.uk>
References: <dccp_bug_fixes_for_net-2.6>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:37419 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756313AbYFJMxv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2008 08:53:51 -0400
In-Reply-To: <dccp_bug_fixes_for_net-2.6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

please consider pulling from

	git://eden-feed.erg.abdn.ac.uk/net-2.6 

This set has bug-fixes only, non-bug fixes will follow at a later stage.

Some test-tree patches need to be reworked with regard to prefix conventions,
will send a request-for-comments later this week to enquire about this.     

Patch #1: Fixes a divide-by-zero bug in CCID-3.
Patch #2: Resolves sparse warnings (gathered from several patches in the tree). 
Patch #3: Enforces that Ack Vectors are not interpreted on request sockets.
Patch #4: Computation error in CCID-3 allowed sending rate.
Patch #5: Sending rate in CCID-3 truncated due to u64 -> u32 conversion.
Patch #6: Typo in initial sequence number assignment.
Patch #7: Bug in the initialisation of v4/v6 request-socket option areas.
