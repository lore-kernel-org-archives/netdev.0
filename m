From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: net-next-2.6 [PATCH 0/6] dccp: miscellaneous fixes and helper functions
Date: Tue, 12 Oct 2010 07:15:45 +0200
Message-ID: <1286860551-6809-1-git-send-email-gerrit@erg.abdn.ac.uk>
References: <dccp_misc_fixes_and_helper_functions___a_set_of_six_patches_sent_today>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:43506 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750758Ab0JLFP5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Oct 2010 01:15:57 -0400
In-Reply-To: <dccp_misc_fixes_and_helper_functions___a_set_of_six_patches_sent_today>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

please can you consider the following set of DCCP patches: the first is a bug
fix, the rest perform refactoring and provide helper functions.

 Patch #1: fixes two problems in the DCCP  (AWL/SWL) window-size adjustment.
 Patch #2: refactors the connect_init() function by combining related code.
 Patch #3: removes an never-user argument from the CCID tx function.
 Patch #4: provides a function to generalize the data-loss condition 
           (patch originally came from the ccid-4 subtree).
 Patch #5: schedules an Ack as carrier for a pending timestamp echo.
 Patch #6: tidies up the format of DCCP per-connection warnings.

The set has also been placed into a fresh (today's) copy of net-next-2.6, on

    git://eden-feed.erg.abdn.ac.uk/net-next-2.6        [subtree 'dccp']

All patches have been in the test tree for a long while and are bisectable.
