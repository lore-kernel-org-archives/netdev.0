From: David Miller <davem@davemloft.net>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at
 000000000000002c
Date: Wed, 01 Feb 2012 16:21:57 -0500 (EST)
Message-ID: <20120201.162157.880976652659067010.davem@davemloft.net>
References: <4F26E72E.2020007@profihost.ag>
	<20120130.164828.1695146432151008554.davem@davemloft.net>
	<4F27A18F.3060907@profihost.ag>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greg@kroah.com, eric.dumazet@gmail.com, jwboyer@gmail.com,
	hch@infradead.org, netdev@vger.kernel.org, david@fromorbit.com,
	stable@vger.kernel.org, gregkh@suse.de
To: s.priebe@profihost.ag
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35049 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932756Ab2BAVXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 16:23:40 -0500
In-Reply-To: <4F27A18F.3060907@profihost.ag>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Date: Tue, 31 Jan 2012 09:08:47 +0100

> Hi David, Hi Greg,
> 
>> In all, I think this request is invalid.
>>
>> You're asking me to submit patches to -stable which don't apply
>> even remotely, and whose dependencies haven't even been applied
>> to the tree.
> 
> i'm sorry but it seems you miss something. The list of matches wasn't
> mine it was the list you kernel guys generated in Dec 2011 while you
> were discussing my NULL pointer dereference.

That bug fix by Eric has lots of dependencies on other sets of
non-trivial changes, so this will be a very difficult backport on many
levels.

Such a non-trivial backport has the danger of adding as many bugs as
it is intended to fix.

Therefore I will not be attempting to make this fix feasible for
3.0.x-stable, sorry.

I seriously suggest that if you really are hitting this race (the
exposure is very small, it only happens if you get redirects and
redirects are not common for most hosts) that you move to a more
recent kernel such as 3.1.x or 3.2.x, both of which have all the
dependencies as well as the bug fix applied.
