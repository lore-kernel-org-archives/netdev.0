From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: net-2.6 [PATCH 0/5] dccp: ccid-2 clean-up; code sharing between TCP and DCCP
Date: Mon, 30 Aug 2010 07:23:09 +0200
Message-ID: <1283145794-5615-1-git-send-email-gerrit@erg.abdn.ac.uk>
References: <ccid2_and_tcp_code_sharing>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:59461 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753664Ab0H3FX0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Aug 2010 01:23:26 -0400
In-Reply-To: <ccid2_and_tcp_code_sharing>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

please can you have a look at the attached set from the DCCP test tree; it 
tidies up CCID-2 code and implements sharing of code common to TCP and DCCP.

Patch #1: aligns CCID-2 timestamps with those used by TCP.
Patch #2: removes redundant CCID-2 sk-timer functions.
Patch #3: consolidates RFC3390 initial-window code common to TCP and CCID-2 
	  (please note that this still uses the old numbers which have been
	   updated by RFC 5681: I'll send a separate patch documenting that).
Patch #4: shares the minimum-RTO code between TCP and CCID-2.
Patch #5: shares the minimum-RTO code between TCP and CCID-3.

All patches have been tested to compile independently and are at the top of
git://eden-feed.erg.abdn.ac.uk/dccp_exp (subtree 'dccp').
