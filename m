From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
	dev_deactivate() race
Date: Sat, 20 Sep 2008 16:25:42 +0900
Message-ID: <20080920072542.GA457@gondor.apana.org.au>
References: <20080913205408.GA2545@ami.dom.local> <20080914061610.GA20571@gondor.apana.org.au> <20080914202715.GA2540@ami.dom.local> <20080920.002137.108837580.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43817 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750867AbYITHZu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 03:25:50 -0400
Content-Disposition: inline
In-Reply-To: <20080920.002137.108837580.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 20, 2008 at 12:21:37AM -0700, David Miller wrote:
>
> The cpu utilization savings exist for case #1 only, and we can
> implement the bypass logic _perfectly_ as described above.
> 
> For #2 there is nothing to check, just do it and see what comes
> out of the qdisc.

Your analysis sounds perfect to me.  And I'm sure happy to see
this thread die as it's starting to take up a significant amount
of space in my mailbox :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
