From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [DCCP] [Patch 0/4]: Further CCID-2 clean-ups
Date: Wed, 27 Feb 2008 14:23:04 +0000
Message-ID: <1204122188-9984-1-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:65386 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753225AbYB0OYA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2008 09:24:00 -0500
In-Reply-To: ccid2_clean_ups
References: ccid2_clean_ups
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Further CCID-2 work - 3 patches are clean-ups, removing unnecessary bits so
that the code becomes clearer. Patch #3 replaces the RTT estimator algorithm -
much work has gone into testing, and the TCP RTO estimator has been chosen -
not simply because it is easy to copy someone else's code, but because it
offers a much better solution, with evidence given.

Patch #1: After finding that the CCID-2 sanity tests are redundant,
          they are removed.
Patch #2: Simplifies decrementing the `pipe' variable in CCID-2, also
          removing redundancies.
Patch #3: Replaces the partly broken RTT estimator with a better
          alternative - reusing the TCP RTT estimator. 
Patch #4: Removes wrappers around sk_timer functions, since these
          do not add any further functionality / benefit. 


All patches have been uploaded - to the end - of the test tree at
	git://eden-feed.erg.abdn.ac.uk/dccp_exp		[dccp]


PLEASE NOTE - there will be a server outage of this server from

	Friday 29th  Feb,   12:00 UTC until
	Monday 3rd   Mar, > 12:00 UTC

due to unavoidable brick and construction work in the building.
