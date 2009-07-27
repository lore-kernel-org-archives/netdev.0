From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: shrink net_device by #ifdef-ing protocol-specific
 members
Date: Mon, 27 Jul 2009 09:27:12 -0700 (PDT)
Message-ID: <20090727.092712.84381944.davem@davemloft.net>
References: <4A6DC314.2010303@ixiacom.com>
	<20090727.082644.265102452.davem@davemloft.net>
	<1248711781.10463.108.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lgrijincu@ixiacom.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52161
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752809AbZG0Q1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 12:27:06 -0400
In-Reply-To: <1248711781.10463.108.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Mon, 27 Jul 2009 09:23:01 -0700

> On Mon, 2009-07-27 at 08:26 -0700, David Miller wrote:
>> From: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>
>> Date: Mon, 27 Jul 2009 18:09:08 +0300
>> > Some members of net_device are used only by some protocols.
>> > If those protocols are not compiled (as modules or linked in) they
>> > should not take up space in the structure.
>> This benefits, at best, %0.000000001 of users of the Linux kernel,
>> because every distribution is going to turn on every single option.
> 
> I think the cost of maintaining this is small and the
> percentage of users that benefit underestimated.

Prove it.

Prove that it helps enough to maintain this ifdef abortion in our
header files.

It only gives the false sense of satisfation that we're making our
datastructures less bloated.  We're not, and in fact they keep getting
larger, and if we add these ifdefs the new excuse for bloat will be
"but it gets compiled out on embedded et al.  builds that don't use
this or that feature."

Putting this crap in is just a big smoke screen which gives a
disincentive for making real improvements in this area.

If I thought this was worthwhile I would have done it 10 years ago.
