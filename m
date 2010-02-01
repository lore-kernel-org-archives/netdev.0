From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [BUG-FIX v2][PATCH 0/2]: recent dccp fixes
Date: Mon,  1 Feb 2010 13:12:18 +0100
Message-ID: <1265026340-5282-1-git-send-email-gerrit@erg.abdn.ac.uk>
References: <20100201120815.GA4424@gerrit.erg.abdn.ac.uk>
Cc: nhorman@tuxdriver.com, dccp@vger.kernel.org,
	netdev@vger.kernel.org, --cc@laptev.erg.abdn.ac.uk
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:35231 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752863Ab0BAMMe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Feb 2010 07:12:34 -0500
In-Reply-To: <20100201120815.GA4424@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

as per your request, I am resending this CC:-ed to Neil (who already acked
the first patch), and also adding Arnaldo.

These are two fixes for recent dccp commits which addressed issues, but
introduced bugs which I discovered when rebasing the test tree last week.

Patch #1: fixes a bug resulting from truncating cache name length.
Patch #2: reverts a commit which introduced a module-loading bug.

This being bugs, would you please consider this for stable too.

The test-tree also has been fixed accordingly,
http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=shortlog;h=ready    
