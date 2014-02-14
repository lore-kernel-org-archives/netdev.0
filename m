From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: remove unnecessary return's
Date: Fri, 14 Feb 2014 13:41:37 -0500 (EST)
Message-ID: <20140214.134137.2289581685154413307.davem@davemloft.net>
References: <alpine.DEB.2.02.1402132327480.1967@localhost6.localdomain6>
	<20140213.181416.1185115361356253646.davem@davemloft.net>
	<alpine.DEB.2.10.1402141055270.2118@hadrien>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, joe@perches.com, stephen@networkplumber.org,
	netdev@vger.kernel.org
To: julia.lawall@lip6.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35306 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751927AbaBNSll (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 13:41:41 -0500
In-Reply-To: <alpine.DEB.2.10.1402141055270.2118@hadrien>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia.lawall@lip6.fr>
Date: Fri, 14 Feb 2014 10:58:00 +0100 (CET)

> On Thu, 13 Feb 2014, David Miller wrote:
> 
>> I think it is valuable, it's so much easier to audit the return paths
>> via a process of elimination with that kind of layout.  A return in
>> the middle of that looks out of place at best.
> 
> Actually, I had a student who made a tool that went the other way around,
> and introduced goto labels for sharable error handling code.  We didn't
> get around to using it to send patches, though.  In that tool, we didn't
> create labels just for returns, with the thought that in that case there
> was no point to introduce a goto if there was nothing to share.

That's one perspective.

But think of it this way, if there is a seqeuence of labels already and
you're scanning for a large body of code for control transfers during
an audit, what are your eyes more likely to miss?

A sequence goto statements targetting well named and distinct labels
or that "return" hidding there somewhere in the middle?
