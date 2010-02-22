From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next 14/15] drivers/net/typhoon.c: Use
 (pr|netdev)_<level> macro helpers
Date: Mon, 22 Feb 2010 15:43:06 -0800 (PST)
Message-ID: <20100222.154306.114398657.davem@davemloft.net>
References: <1266804176.10646.65.camel@Joe-Laptop.home>
	<1266808127.10646.77.camel@Joe-Laptop.home>
	<1266808995.2930.24.camel@obelisk.thedillows.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org
To: dave@thedillows.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43853
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754643Ab0BVXms (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2010 18:42:48 -0500
In-Reply-To: <1266808995.2930.24.camel@obelisk.thedillows.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Dillow <dave@thedillows.org>
Date: Sun, 21 Feb 2010 22:23:15 -0500

> On Sun, 2010-02-21 at 19:08 -0800, Joe Perches wrote: 
>> David Dillow took my suggestions and improved on them.
>> Here is this latest version.
>> 
>> Add #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
>> Remove #define PFX
>> Remove #define ERR_PFX
>> Remove now unused member name from struct typhoon
>> Use pr_<level>
>> Use netdev_<level>
>> Coalesce long formats
>> Remove version information
>> 
>> Signed-off-by: Joe Perches <joe@perches.com>
>> Signed-off-by: David Dillow <dave@thedillows.org>
> 
> Perhaps commit text as follows?

Man you are picky :-/  Are you a control freak?

You can't even let Joe write his commit comments consistently with the
ones he is using for all the other similar network driver transmations?

What makes doing the same exact transformations to your favorite
driver so special that it deserves a specially constructed commit
message?

Tell me.

Stuff like this drives me crazy.
