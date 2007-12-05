From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH v2 0/3][BUG-FIX]: Test tree updates and bug fixes
Date: Wed,  5 Dec 2007 11:19:43 +0000
Message-ID: <11968535863312-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: netdev@vger.kernel.org
To: dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:61783 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751656AbXLELUB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2007 06:20:01 -0500
In-Reply-To: ccid3_updates_and_bug_fixes
References: ccid3_updates_and_bug_fixes
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Orthogonal to the ongoing discussion of patches, here are updates
of existing ones. This is mainly to keep the test tree in synch;
I'd like to upload the new test tree since -rc4 is out.

Arnaldo has actually pointed out more bugs than I have given him credit for,
these are contained in this patch set.

Patch #1: Fixes the allocation of per-socket RX history array elements
          (implements the solution contributed by Arnaldo).

Patch #2: Fixes a similar problem in the tfrc_module.c -- this solution
          is also present in Arnaldo's patch set, but he did not explicitly
	  point it out. The update fixes this problem (it used to disappear
	  later in the patch set, when the full initialisation was made for
	  TX/RX histories and Loss Intervals; so it is only temporary).

Patch #3: Removes the redundant test "len > 0", as a result one inline function
          becomes obsolete. Thanks is again due to Arnaldo.

I have not yet updated the CCID4 subtree with regard to patch#3 but will do
as soon as work here permits.

The updates to the tree are now available at
 	git://eden-feed.erg.abdn.ac.uk/dccp_exp		{dccp,ccid4} 

