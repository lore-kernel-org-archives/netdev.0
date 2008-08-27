From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: net-next-2.6 [pull-request] [PATCH 0/6]: DCCP code updates
Date: Wed, 27 Aug 2008 07:35:19 +0200
Message-ID: <1219815325-13778-1-git-send-email-gerrit@erg.abdn.ac.uk>
References: <20080827050636.GB6760@gerrit.erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:46922 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751591AbYH0Ffe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 01:35:34 -0400
In-Reply-To: <20080827050636.GB6760@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

can you please consider pulling this set - consisting mainly of code updates
with regard to the RFC, and a few other minor updates.

Patch #1: Update to always respond with Reset to option errors, as per the RFC. 
Patch #2: Another update with regard to RFC 4340 - ignore nonsensical options.
Patch #3: Third update with regard to the RFC - fill in the Reset-Data fields.
Patch #4: Update to flush the write queue when disconnecting.
Patch #5: Allow runtime toggling of the `debug' switches via sysfs.
Patch #6: Replaces an unnecessary CCID-3 BUG_ON with a (better) condition.

This code has been tested and been in the DCCP test tree for some while. 

Applied to a fresh (today) copy of net-next-2.6, the patches can be pulled from

	git://eden-feed.erg.abdn.ac.uk/net-next-2.6	[subtree `master']

After this set, the feature-negotiation patch set is the next piece of work.
I will be needing input with regard to prevailing prefix conventions and update
the set to match these - will post this separately.

Gerrit
