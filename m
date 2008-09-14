From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
	dev_deactivate() race
Date: Sat, 13 Sep 2008 23:16:10 -0700
Message-ID: <20080914061610.GA20571@gondor.apana.org.au>
References: <20080913011018.GA10242@gondor.apana.org.au> <20080912.182259.238925690.davem@davemloft.net> <20080913012758.GA10459@gondor.apana.org.au> <20080912.184008.74354363.davem@davemloft.net> <20080913014800.GA10611@gondor.apana.org.au> <20080913205408.GA2545@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kaber@trash.net
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33235 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751297AbYINGQU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Sep 2008 02:16:20 -0400
Content-Disposition: inline
In-Reply-To: <20080913205408.GA2545@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 13, 2008 at 10:54:08PM +0200, Jarek Poplawski wrote:
>
> If I get it right peek + dequeue should do all current dequeue logic
> plus additionally write down the child qdisc or skb (leaves) info,
> plus, probably, some ifs btw., which looks like a bit of overhead,
> if we consider requeuing as something exceptional. Unless we don't -
> then of course something like this could be useful.

I don't see the overhead in writing down something that we alrady
have.  In any case, do you have an alternative solution to the
current problem that qdisc_run looks at an arbitrary queue's
status to decide whether it should process a qdisc that empties
into n queues?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
