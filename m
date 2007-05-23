From: David Miller <davem@davemloft.net>
Subject: Re: bad networking related lag in v2.6.22-rc2
Date: Wed, 23 May 2007 14:30:56 -0700 (PDT)
Message-ID: <20070523.143056.115914753.davem@davemloft.net>
References: <46541DC4.4090501@trash.net>
	<20070523112559.GA24604@gondor.apana.org.au>
	<20070523114021.GA21880@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, kaber@trash.net,
	kernel@prachanda.info, linux-kernel@vger.kernel.org,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	tglx@linutronix.de, netdev@vger.kernel.org
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32881
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754072AbXEWVax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2007 17:30:53 -0400
In-Reply-To: <20070523114021.GA21880@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ingo Molnar <mingo@elte.hu>
Date: Wed, 23 May 2007 13:40:21 +0200

> 
> * Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > [NET_SCHED]: Fix qdisc_restart return value when dequeue is empty
> > 
> > My previous patch that changed the return value of qdisc_restart 
> > incorrectly made the case where dequeue returns empty continue 
> > processing packets.
> > 
> > This patch is based on diagnosis and fix by Patrick McHardy.
> > 
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> also:
> 
>   Reported-and-debugged-by: Anant Nitya <kernel@prachanda.info>

Applied, thanks everyone.
