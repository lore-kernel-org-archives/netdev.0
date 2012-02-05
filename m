From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: move ethtool include to where its used
Date: Sun, 05 Feb 2012 00:24:03 -0500 (EST)
Message-ID: <20120205.002403.528386341681036443.davem@davemloft.net>
References: <1328267822-25690-1-git-send-email-vapier@gentoo.org>
	<20120204.162331.1482938799603820869.davem@davemloft.net>
	<201202042120.14192.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vapier@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38297 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750786Ab2BEFYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2012 00:24:20 -0500
In-Reply-To: <201202042120.14192.vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier@gentoo.org>
Date: Sat, 4 Feb 2012 21:20:07 -0500

> On Saturday 04 February 2012 16:23:31 David Miller wrote:
>> From: Mike Frysinger <vapier@gentoo.org>
>> > The linux/mii.h headers has long been standalone for userspace.  But a
>> > recent commit added linux/ethtool.h to the include list even when it
>> > isn't used.  Since we only need this with __KERNEL__, move the include
>> > down to the right spot.  Now userland no longer needs to pull this in.
>> 
>> I don't understand what the problem is.
> 
> the exported linux/mii.h userspace code doesn't need linux/ethtool.h, thus it 
> should not need to include it

So there's not bug, you're just twiddling.

I don't think there should be any rule that just because the stuff
needed by a header is in __KERNEL__ we have to put the include in
there too, if the header in question is userspace clean itself.

It's so damn ugly, and error prone during audits (ie. easy to miss),
to have include directives not at the top of the file.

So I'm really not interested at all in applying patches like this
one, sorry.
