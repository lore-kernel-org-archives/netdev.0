From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 0/2] [RFT] [DCCP]: Bug fix and a new sending-policy interface
Date: Mon, 12 May 2008 08:48:02 +0100
Message-ID: <1210578484-12571-1-git-send-email-gerrit@erg.abdn.ac.uk>
References: <bug_fix_and_qpolicy_interface>
Mime-Version: 1.0
Cc: tomasz@grobelny.oswiecenia.net, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:63235 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756445AbYELHsd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 May 2008 03:48:33 -0400
In-Reply-To: <bug_fix_and_qpolicy_interface>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One bug fix and a new packet dequeuing interface for DCCP developed by
Tomasz Grobelny, which has been discussed on dccp@vger.

Patch #1: Bug fix for CCID-3 (ported to CCID-4, too), where a too high t_delta
          (RFC 3448, 4.6) was used. Analysis shows that the t_delta socket 
	  field is not meaningful, it is replaced by an appropriate constant.

Patch #2: Provides a new basis/interface for sending packets, allowing the
          user to set different send policies. This is especially interesting
	  for multimedia applications which have to interact with the congestion
	  control part of DCCP, where packets may be have different priorities
	  (I/P/B video frames, re-synch frames) and may be subject to a
	  playout.


Test tree disclaimer: 
=====================
All patches are eventually meant for mainline but are kept in the DCCP test
tree for testing and possible improvement. Comments and in particular testing
are therefore especially welcome.

The DCCP test tree contains the most recent bug fixes and code updates. The
attribute `test' does not indicate minor quality - all patches have been 
checked, the entire tree is fully bisectable and has been compile-tested on
several different platforms.

It can be checked out from
	git://eden-feed.erg.abdn.ac.uk/dccp_exp
	-> subtree `dccp' for DCCP test tree
	-> subtree `ccid4' for CCID-4 subtree

Further information is on
http://www.linux-foundation.org/en/Net:DCCP_Testing#Experimental_DCCP_source_tree


The University of Aberdeen is a charity registered in Scotland, No SC013683.

