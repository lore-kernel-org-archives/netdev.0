From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: dccp test-tree [PATCH 0/3] ccid-2: Congestion Window Validation, TCP code sharing
Date: Fri, 13 Aug 2010 07:21:38 +0200
Message-ID: <1281676901-7018-1-git-send-email-gerrit@erg.abdn.ac.uk>
References: <ccid2_cwv_dccp_test_tree>
Cc: netdev@vger.kernel.org
To: dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:51685 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751785Ab0HMFdU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Aug 2010 01:33:20 -0400
In-Reply-To: <ccid2_cwv_dccp_test_tree>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a small set to enhance CCID-2, consisting mainly of Congestion Window
Validation (RFC 2681) ported over from TCP.

The first patch allows to make the TCP minimum RTO visible also to CCID-2. Since
CCID-3 also uses RTO (in the formula and for the nofeedback timer), I wonder
whether we should also do the same for CCID-3??

The changeset is:

  Patch #1: makes TCP's minimum-RTO code available to CCID-2
  Patch #2: simplifies the code by using an existing function
  Patch #3: implements CWV for CCID-2 -- largely taken from TCP

The patches have been dusted off from my development tree. They have been tested,
though it is some time ago. Hence I'd very much appreciate review and comments.

	git://eden-feed.erg.abdn.ac.uk/dccp_exp		[subtree 'dccp']
