From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Remove deprecated print_mac to fix warnings
Date: Sun, 06 Dec 2009 11:30:24 -0800 (PST)
Message-ID: <20091206.113024.161211095.davem@davemloft.net>
References: <20091206140828.GA8600@basil.fritz.box>
	<20091206.111739.40602157.davem@davemloft.net>
	<20091206191926.GX18989@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35691
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757483AbZLFTaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Dec 2009 14:30:21 -0500
In-Reply-To: <20091206191926.GX18989@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Sun, 6 Dec 2009 20:19:26 +0100

> On Sun, Dec 06, 2009 at 11:17:39AM -0800, David Miller wrote:
>> From: Andi Kleen <andi@firstfloor.org>
>> Date: Sun, 6 Dec 2009 15:08:28 +0100
>> 
>> > Remove deprecated and unused print_mac to fix warnings
>> > 
>> > There seems to be no user in tree of print_mac left. So just remove it.
>> > 
>> > This eliminates two compiler warnings for every build, because gcc
>> > complains about the deprecated use of the symbol in its EXPORT_SYMBOL.
>> > 
>> > Signed-off-by: Andi Kleen <ak@linux.intel.com>
>> 
>> davem@sunset:~/src/GIT/net-next-2.6$ git grep print_mac
>> davem@sunset:~/src/GIT/net-next-2.6$ 
> 
> Great. I grepped in linux-next, but perhaps I raced with you.

It's been removed in net-next-2.6 for weeks.

> But could that please be fixed in a 2.6.32 stable too? the warnings 
> on every build are annoying.

Sorry, no.
