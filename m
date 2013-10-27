From: Dave Taht <dave.taht@bufferbloat.net>
Subject: Re: 16% regression on 10G caused by TCP small queues
Date: Sat, 26 Oct 2013 21:33:52 -0700
Message-ID: <20131027043351.GA27876@lists.bufferbloat.net>
References: <CAOaVG15indAxBz7E-T+9MK03indiXBa0UhQZ5j6K5DxYP44Mxg@mail.gmail.com>
 <20131023.233816.1396918839771657154.davem@davemloft.net>
 <20131023214557.386aad1a@nehalam.linuxnetplumber.net>
 <20131024.030121.477884925478012615.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stephen@networkplumber.org, ncardwell@google.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.bufferbloat.net ([149.20.54.82]:46303 "EHLO
	huchra.bufferbloat.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750914Ab3J0Edy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Oct 2013 00:33:54 -0400
Content-Disposition: inline
In-Reply-To: <20131024.030121.477884925478012615.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 24, 2013 at 03:01:21AM -0400, David Miller wrote:
> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Wed, 23 Oct 2013 21:45:57 -0700
> 
> > Sorry, thought sk_pacing_rate depended on FQ qdisc but it is other way around.
> > In which case doing merge of these two was sufficient to fix the problem.
> > With a minor manual fix up to tcp.h.
> 
> I know, I already have a half-built tree of -stable submissions
> that does exactlty this.

I know that the "fq" qdisc is not exactly a -stable thing, but if it's simpler
to include it rather than sort through the patch sets, I'm all for it.
