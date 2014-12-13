From: David Miller <davem@davemloft.net>
Subject: Re: [bisected] tg3 broken in 3.18.0?
Date: Fri, 12 Dec 2014 20:18:31 -0500 (EST)
Message-ID: <20141212.201831.186234837340644301.davem@davemloft.net>
References: <548B00CD.3030708@gmail.com>
	<20141212203134.GA23705@teela.fritz.box>
	<20141213011408.GA27568@teela.fritz.box>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nholland@tisys.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40882 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932599AbaLMBSe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 20:18:34 -0500
In-Reply-To: <20141213011408.GA27568@teela.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nils Holland <nholland@tisys.org>
Date: Sat, 13 Dec 2014 02:14:08 +0100

> Ok folks,
> 
> I now took the time to bisect the issue that killed the tg3 network
> interface on one of my boxes in 3.18.0. Beside me, at least one other
> person was affected, although we also have a confirmed report of
> another person using tg3 without issues under 3.18.0.
> 
> My bisect exercise suggests that the following commit is the culprit:
> 
> 89665a6a71408796565bfd29cfa6a7877b17a667 (PCI: Check only the Vendor
> ID to identify Configuration Request Retry)
> 
> In case that rings a bell for anyone, I'd be more than glad to hear
> about it! Otherwise, while I'm no expert at this, I'll do some more
> investigations tomorrow. It's gotten kind of late during bisecting and
> I'm off for some sleep now. ;-)

You definitely need to bring this up with the author of that change
and the relevent list for the PCI subsystem and/or linux-kernel.
