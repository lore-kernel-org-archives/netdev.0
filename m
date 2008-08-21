From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [RFC/RFT] [PATCH 0/3] dccp: Updates for parsing header options
Date: Thu, 21 Aug 2008 19:19:45 +0200
Message-ID: <1219339188-31873-1-git-send-email-gerrit@erg.abdn.ac.uk>
References: <test_tree_updates_for_parsing_header_options>
Cc: netdev@vger.kernel.org
To: dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:36303 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752671AbYHURT7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Aug 2008 13:19:59 -0400
In-Reply-To: <test_tree_updates_for_parsing_header_options>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an update of the test tree with regard to parsing DCCP header options.

Patch #1: Changes the policy to silently ignore header options with nonsensical
          lengths, as specified in RFC 4340, 5.8.
Patch #2: Fills in the Data1...3 fields as required for "Option Error" Resets.
Patch #3: Is a reworked version of an existing test tree patch which has been
          fixed to return the (hopefully) correct Reset code in each error case.


The set has been compile-tested and updates (-rc4) have been uploaded to

	git://eden-feed.erg.abdn.ac.uk/dccp_exp		[subtree `dccp']

Review and comments are welcome.

