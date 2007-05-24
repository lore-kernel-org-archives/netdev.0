From: Anant Nitya <kernel@prachanda.info>
Subject: Re: bad networking related lag in v2.6.22-rc2
Date: Thu, 24 May 2007 12:42:29 +0530
Message-ID: <200705241242.32125.kernel@prachanda.hub>
References: <46541DC4.4090501@trash.net> <20070523114021.GA21880@elte.hu> <20070523.143056.115914753.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, mingo@elte.hu,
	herbert@gondor.apana.org.au, kaber@trash.net,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	tglx@linutronix.de, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [208.97.132.5] ([208.97.132.5]:40399 "EHLO
	spaceymail-a2.g.dreamhost.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755048AbXEXHOo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 03:14:44 -0400
In-Reply-To: <20070523.143056.115914753.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 24 May 2007 03:00:56 David Miller wrote:
> From: Ingo Molnar <mingo@elte.hu>
> Date: Wed, 23 May 2007 13:40:21 +0200
>
> > * Herbert Xu <herbert@gondor.apana.org.au> wrote:
> > > [NET_SCHED]: Fix qdisc_restart return value when dequeue is empty
> > >
> > > My previous patch that changed the return value of qdisc_restart
> > > incorrectly made the case where dequeue returns empty continue
> > > processing packets.
> > >
> > > This patch is based on diagnosis and fix by Patrick McHardy.
> > >
> > > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> >
> > also:
> >
> >   Reported-and-debugged-by: Anant Nitya <kernel@prachanda.info>
>
> Applied, thanks everyone.

Networking lag I been seeing since 2.6.22-rc1, disappeared after applying this 
patch. Thanks to everyone who helped me run my system sane again. :)

Reagards
Ananitya

-- 
Out of many thousands, one may endeavor for perfection, and of
those who have achieved perfection, hardly one knows Me in truth.
				-- Gita Sutra Of Mysticism
