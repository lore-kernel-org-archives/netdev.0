From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH net-next] net: remove unnecessary return's
Date: Fri, 14 Feb 2014 13:48:03 -0500
Message-ID: <20140214184803.GA16115@redhat.com>
References: <alpine.DEB.2.02.1402132327480.1967@localhost6.localdomain6>
 <20140213.181416.1185115361356253646.davem@davemloft.net>
 <alpine.DEB.2.10.1402141055270.2118@hadrien>
 <20140214.134137.2289581685154413307.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall@lip6.fr, joe@perches.com, stephen@networkplumber.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49713 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752102AbaBNSsU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Feb 2014 13:48:20 -0500
Content-Disposition: inline
In-Reply-To: <20140214.134137.2289581685154413307.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 14, 2014 at 01:41:37PM -0500, David Miller wrote:
 > From: Julia Lawall <julia.lawall@lip6.fr>
 > Date: Fri, 14 Feb 2014 10:58:00 +0100 (CET)
 > 
 > > On Thu, 13 Feb 2014, David Miller wrote:
 > > 
 > >> I think it is valuable, it's so much easier to audit the return paths
 > >> via a process of elimination with that kind of layout.  A return in
 > >> the middle of that looks out of place at best.
 > > 
 > > Actually, I had a student who made a tool that went the other way around,
 > > and introduced goto labels for sharable error handling code.  We didn't
 > > get around to using it to send patches, though.  In that tool, we didn't
 > > create labels just for returns, with the thought that in that case there
 > > was no point to introduce a goto if there was nothing to share.
 > 
 > That's one perspective.
 > 
 > But think of it this way, if there is a seqeuence of labels already and
 > you're scanning for a large body of code for control transfers during
 > an audit, what are your eyes more likely to miss?
 > 
 > A sequence goto statements targetting well named and distinct labels
 > or that "return" hidding there somewhere in the middle?

No argument about 'in the middle', but the suggestion upthread was for
the very first case before there are any allocations etc that need unwinding.

	Dave
