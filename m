From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 14/15] drivers/net/typhoon.c: Use
 (pr|netdev)_<level> macro helpers
Date: Wed, 17 Feb 2010 19:10:02 -0800 (PST)
Message-ID: <20100217.191002.240804576.davem@davemloft.net>
References: <1266460221.5719.60.camel@obelisk.thedillows.org>
	<20100217.184100.232538560.davem@davemloft.net>
	<1266462064.5719.78.camel@obelisk.thedillows.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: dave@thedillows.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56843
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757225Ab0BRDJv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 22:09:51 -0500
In-Reply-To: <1266462064.5719.78.camel@obelisk.thedillows.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Dillow <dave@thedillows.org>
Date: Wed, 17 Feb 2010 22:01:04 -0500

> On Wed, 2010-02-17 at 18:41 -0800, David Miller wrote:
>> From: David Dillow <dave@thedillows.org>
>> Date: Wed, 17 Feb 2010 21:30:21 -0500
>> 
>> > No, because the routines that use tp->name are called both before and
>> > after the netdev is registered. Prior to that time, it contains the PCI
>> > slot name -- "00:01.0" etc -- so that the user can determine which card
>> > is acting up. Once the card is registered, it has "ethX" to use a
>> > commonly expected name for the card.
>> 
>> In my opinion that's awful.
> 
> Neither you nor Jeff seemed to think it was an issue 7+ years ago, and
> Jeff liked it when it was suggested as a solution to another driver's
> problems.

I didn't even realize it was an issue and we also didn't have the nice
dev_*() macros back there.

> But times change, sure. And people learn from experience.

Right.

> I liked it because it consistent with eth device naming when it could
> be, and gave them useful info to go on when it failed during
> initialization.

How can printing a PCI device name string be consistent with eth
device naming?

> I'm perfectly fine with the netdev_<level> changes, and can grudgingly
> live with the overlong format strings, but the pr_<level> changes make
> the output worse, and don't help readability or maintainability in my
> opinion. I'm don't see how dropping the typhoon patch slows Joe down, so
> I'd like to avoid having to fix things up after the fact.

I already tossed his patch from my tree.

