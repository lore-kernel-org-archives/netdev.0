From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 18492] New: kernel softirq warning on boot
Date: Wed, 15 Sep 2010 21:40:37 -0700 (PDT)
Message-ID: <20100915.214037.90800289.davem@davemloft.net>
References: <20100914135730.8af6bc76.akpm@linux-foundation.org>
	<20100914.141103.123996613.davem@davemloft.net>
	<20100915064655.GA21021@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, hramrach@centrum.cz,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40245
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750807Ab0IPEkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 00:40:18 -0400
In-Reply-To: <20100915064655.GA21021@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 15 Sep 2010 14:46:55 +0800

> On Tue, Sep 14, 2010 at 02:11:03PM -0700, David Miller wrote:
>>
>> I'll take a closer look at this if Herbert doesn't beat me to it.
> 
> I thought we were going to use this patch until Paul's BH warning
> removal made it into mainline?
> 
> netpoll: Disable IRQ around RCU dereference in netpoll_rx

I hadn't anticipated it taking this long for Paul's patch to
get upstream.

So I only queued this up for -stable, not Linus's tree.

Paul has started the work of moving his patch upstream, so I suspect
that if I queued this patch of our's up to my tree now it would land
in Linus's tree about the same time :-)

If something non-trivially stalls Paul's submission work, we can
queue this up.
