From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [net-2.6 PATCH 0/6] dccp: ICMP bug fixes by Wei Yongjun
Date: Fri, 25 Jul 2008 10:02:52 +0100
Message-ID: <1216976578-17767-1-git-send-email-gerrit@erg.abdn.ac.uk>
References: <dccp_icmp_payload_bug_fixes>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:52394 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751819AbYGYJDP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jul 2008 05:03:15 -0400
In-Reply-To: <dccp_icmp_payload_bug_fixes>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, 

can you please have a look at this set of ICMP/DCCP bug fixes by Wei Yongjun,
augmented by two inter-related test tree patches that solve a related bug.

Patch #1: Provides a way to distinguish original from retransmitted packets.
Patch #2: Fixes a bug - AWL was never updated. Needed by the third patch.
Patch #3: Corrects ICMPv4 sequence number check to use AWL/H instead of SWL/H.
Patch #4: Implements check from patch #3 for ICMPv6.
Patch #5: Fixes an insufficient-length check for 

All patches have been compile-tested, the first two have been in the test
tree for over at least one month.

Can you please consider pulling from

	git://eden-feed.erg.abdn.ac.uk/net-2.6		(subtree `master')

At your discretion, as none of the bugs is severe,

   	git://eden-feed.erg.abdn.ac.uk/net-next-2.6	(subtree `master')

contains the same set of patches. Both trees have been freshly cloned today.	
