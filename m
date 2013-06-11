From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 03/03] [PATCH] vxlan: fix crash on module removal
Date: Mon, 10 Jun 2013 21:10:42 -0700 (PDT)
Message-ID: <20130610.211042.487361296749139130.davem@davemloft.net>
References: <20130610.141421.1570141372448161465.davem@davemloft.net>
	<20130610.141816.1546753299816672552.davem@davemloft.net>
	<20130610144814.44aca116@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34654 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750757Ab3FKEKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jun 2013 00:10:45 -0400
In-Reply-To: <20130610144814.44aca116@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 10 Jun 2013 14:48:14 -0700

> The issue was trying to split them into net and net-next series.
> If I sent one series, would you be able to handle that?

Everyone who wants to do this, does it like this:

1) You give me the "net" series with the bug fixes.

2) You give me the "net-next" series, and you tell me "this series
   depends upon the bug fixes going into 'net' from series X, please
   merge that into 'net-next' before applying this series.

And if you're really testing this stuff at all, that's how you're
developing and testing it too.  You put together the net patch set,
you _build_ it and you _test_ it.  Then you make a branch on
net-next, pull your 'net' stuff into it, and the build your 'net-next'
series on that branch.  Then you _build_ it and you _test_ it before
even thinking about posting it here.
