From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [IPVS] replace if .. goto with while
Date: Tue, 02 Jan 2007 00:38:39 -0800 (PST)
Message-ID: <20070102.003839.08324311.davem@davemloft.net>
References: <20061218031110.GA32036@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wensong@linux-vs.org, ja@ssi.bg,
	ratz@drugphish.ch, jmack@wm7d.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51106
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932983AbXABIik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jan 2007 03:38:40 -0500
To: horms@verge.net.au
In-Reply-To: <20061218031110.GA32036@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Horms <horms@verge.net.au>
Date: Mon, 18 Dec 2006 12:11:11 +0900

> I guess that this code used to be more complex, but replacing
> the goto with a while seems to make things a bit more readable.
> Or in other words, two fairly gratuitous goto are removed.
> 
> On a related note, I wonder if there should be a limit to how
> many times it tries.
> 
> Signed-Off-By: Simon Horman <horms@verge.net.au>

Yes, there should be, something like a limit of one. :-)

There is no reason to loop on something like this, just
return a failure immediately if creating the kernel thread
fails.

As a side note, if it's easy you might want to convert this
over the the include/linux/kthread.h interfaces.  I just did
this for pktgen tonight and it cleaned a lot of stuff up.
