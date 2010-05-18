From: David Miller <davem@davemloft.net>
Subject: Re: [0/4] Fix addrconf race conditions
Date: Tue, 18 May 2010 15:27:59 -0700 (PDT)
Message-ID: <20100518.152759.218054760.davem@davemloft.net>
References: <20100423150540.GA26611@gondor.apana.org.au>
	<20100518110243.GA7750@gondor.apana.org.au>
	<20100518102550.65ad3fdd@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jbohac@suse.cz,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56859
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752947Ab0ERW1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 18:27:50 -0400
In-Reply-To: <20100518102550.65ad3fdd@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 18 May 2010 10:25:50 -0700

> I wonder if so many fine grained locks are really necessary at
> all.  Everything but timers looks like it is under RTNL mutex
> already.

I can't see any reasonable alternative, and it took weeks to get
a fix at all.

So I'm going to apply Herbert's fixes with the __KERNEL__ header
bit fixed up.

Thanks Herbert!
