From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [BUG-FIX][PATCH 0/2]: recent dccp fixes
Date: Mon,  1 Feb 2010 07:18:05 +0100
Message-ID: <1265005087-5549-1-git-send-email-gerrit@erg.abdn.ac.uk>
References: <recent-dccp-bug-fixes-jan-2010>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:59435 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754329Ab0BAG35 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Feb 2010 01:29:57 -0500
In-Reply-To: <recent-dccp-bug-fixes-jan-2010>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In January there were two dccp commits introducing bugs. Having
been guilty of ack-ing them, please find below patches to fix
them.

Patch #1: fixes a bug resulting from truncating cache name length.
Patch #2: reverts a commit which introduced a module-loading bug.

This being bugs, would you please consider this for stable too.

The test-tree also has been fixed accordingly,
http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=shortlog;h=ready    
