From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] LRO ack aggregation
Date: Mon, 19 Nov 2007 22:22:14 -0800 (PST)
Message-ID: <20071119.222214.81458569.davem@davemloft.net>
References: <20071119.210919.177660672.davem@davemloft.net>
	<E1IuMIQ-0003gc-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gallatin@myri.com, netdev@vger.kernel.org, ossthema@de.ibm.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39628
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751983AbXKTGWP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 01:22:15 -0500
In-Reply-To: <E1IuMIQ-0003gc-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 20 Nov 2007 14:09:18 +0800

> David Miller <davem@davemloft.net> wrote:
> >
> > Fundamentally, I really don't like this change, it batches to the
> > point where it begins to erode the natural ACK clocking of TCP, and I
> > therefore am very likely to revert it before merging to Linus.
> 
> Perhaps make it a tunable that defaults to off?

That's one idea.

But if it's there the risk it to have it end up being turned on
always by distribution vendors, making our off-default pointless
and the internet gets crapped up with misbehaving Linux TCP
stacks anyways.
