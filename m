From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: dccp test tree [RFC/RFC] [Patch 0/3] dccp: CCID-independent
	connection probing
Date: Mon, 5 Jan 2009 15:41:52 +0100
Message-ID: <20090105144152.GA3773@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: dccp@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:43916 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754411AbZAEOmB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jan 2009 09:42:01 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This submission presents recent updates of the DCCP test tree, it is
meant to generate feedback but not as a submission of mainline patches.

These three patches reflect recent work and available via the tree on

	git://eden-feed.erg.abdn.ac.uk
	subtrees 'dccp' and 'ccid4'.

The two patches have been mentioned several times before, now there was
time to realise them.

Patch #1: Updates the Kconfig menu, minor cosmetics.

Patch #2: Removes CCID-3 specific code from dccp_probe and
          generates a plugin function point that can be used
	  by other subsystems (for instance, it is also used
          to use dccp_probe with CCID-4).
	  The now unused 'size' field is used to detail the
	  CCID number, which is useful for automatic analysis
	  of the output (test plot scripts available).

Patch #3: Based on patch #2, it equips CCID-2 with dccp_probe
          functionality. Please note that the patch is deeper
	  in the test tree, since it requires on the other
	  patches of the test tree to make srtt/mdev/rto available.


Comments welcome.

Gerrit


Patch stats
-----------
 ccid.h        |   11 +++++++++++
 ccids/Kconfig |   58 +++++++++++++++++++++++++++++-----------------------------
 ccids/ccid2.c |   14 ++++++++++++++
 ccids/ccid3.c |   14 ++++++++++++++
 dccp.h        |   11 ++++++++++-
 probe.c       |   29 ++++++++++++-----------------
 6 files changed, 90 insertions(+), 47 deletions(-)
