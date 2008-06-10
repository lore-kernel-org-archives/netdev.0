From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/7] dccp ccid-3: Bug-Fix - Zero RTT is possible
Date: Tue, 10 Jun 2008 12:31:15 -0700 (PDT)
Message-ID: <20080610.123115.107060915.davem@davemloft.net>
References: <dccp_bug_fixes_for_net-2.6>
	<1213102423-27486-1-git-send-email-gerrit@erg.abdn.ac.uk>
	<1213102423-27486-2-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34098
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753409AbYFJTbP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2008 15:31:15 -0400
In-Reply-To: <1213102423-27486-2-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 10 Jun 2008 13:53:37 +0100

> Commit 825de27d9e40b3117b29a79d412b7a4b78c5d815 fixed the CCID-3 window counter
> computation for RTTs < 4 microseconds (as happens on loopback).

When referencing GIT SHA1 IDs in commit logs, always
provide the commit changelog header line text like
this:

	In commit $(SHA1_ID) ("[DCCP]: blah blah blah") we
	did whatever...

because if this patch is ported into another GIT tree,
the SHA1_ID of the referenced commit might be different
and the commit header line text helps people find the
correct change you are referring to even if this happens.

I say this to someone at least one time every day that I
integrate patches.  Please be mindful of this so I don't
have to ask you to do it again, thanks.
