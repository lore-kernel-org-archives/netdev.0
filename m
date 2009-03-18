From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] fix sctp breakage
Date: Wed, 18 Mar 2009 03:25:08 +0000
Message-ID: <20090318032508.GY28946@ZenIV.linux.org.uk>
References: <20090318031405.GX28946@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:51918 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753367AbZCRDZM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 23:25:12 -0400
Content-Disposition: inline
In-Reply-To: <20090318031405.GX28946@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 18, 2009 at 03:14:05AM +0000, Al Viro wrote:
> broken by commit 5e739d1752aca4e8f3e794d431503bfca3162df4; AFAICS should
> be -stable fodder as well...

PS: existing code *DOES* produce correct value; sizeof in question is
4, and htons(4) + htons(2) happens to be equal to htons(6) (no carryover).
So before anyone starts moaning about coverups again, no, this is not
a roothole fix we are trying to get past grsec tossers.

It needs fixing, though, accidentally correct value or not.
