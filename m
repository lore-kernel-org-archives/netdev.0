From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 0/4] [TFRC]: Revised Loss Intervals Patches (macro-less, new swap function)
Date: Mon, 10 Dec 2007 13:11:54 +0000
Message-ID: <1197292318-29659-1-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:38184 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751075AbXLJNNA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Dec 2007 08:13:00 -0500
In-Reply-To: dccp_tfrc_loss_intervals_revised_patch_set
References: dccp_tfrc_loss_intervals_revised_patch_set
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This revision updates earlier patches, following discussion,
and adds one additional cleanup patch at the end.


Patch #1: Revision of initialisation patch; fixed calling __exit function 
          from __init function - identified by Arnaldo.

Patch #2: Revision - re-converted tfrc_rx_hist_entry() back to inline,
          following discussion with Arnaldo.

Patch #3: Reworked - loss intervals database.  Individual changes:
     	  - replaced tfrc_rx_hist_swap() with routine suggested by Arnaldo;
	  - replaced all access macros with inlines or in-place(s);
	  - replaced LIH_INDEX also with inline instead of macro.
          
Patch #4: Removes redundant debugging output from syslog.
