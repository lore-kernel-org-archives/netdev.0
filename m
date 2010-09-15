From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: net-next-2.6 [PATCH 0/3] dccp: ccid-3 fixes and simplifications
Date: Wed, 15 Sep 2010 14:10:20 +0200
Message-ID: <1284552623-16283-1-git-send-email-gerrit@erg.abdn.ac.uk>
References: <dccp_ccid3_simplifications>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:56033 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752002Ab0IOMKg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Sep 2010 08:10:36 -0400
In-Reply-To: <dccp_ccid3_simplifications>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

please find attached a set of 3 CCID-3 patches from the test tree.
All have been in the test tree a long time and compile independently.

 Patch #1: Fixes a bug and simplifies the packet scheduling algorithm.
 Patch #2: Replaces buggy RTT sampling history lookup.
 Patch #3: Simplifies the CCID-3 tx-option parsing routine.

This set is also available based on a fresh (today's) copy of net-next-2.6, 

	git://eden-feed.erg.abdn.ac.uk/net-next-2.6  [subtree 'dccp']

