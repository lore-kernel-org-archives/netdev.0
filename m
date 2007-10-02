From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tcp bw in 2.6
Date: Tue, 02 Oct 2007 18:52:54 +0800
Message-ID: <E1IcfN0-0007tt-00@gondolin.me.apana.org.au>
References: <20071002005917.GB5480@bitmover.com>
Cc: torvalds@linux-foundation.org, davem@davemloft.net,
	wscott@bitmover.com, netdev@vger.kernel.org
To: lm@bitmover.com (Larry McVoy)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1491 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752030AbXJBKxi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 06:53:38 -0400
In-Reply-To: <20071002005917.GB5480@bitmover.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Larry McVoy <lm@bitmover.com> wrote:
>
> One of my clients also has gigabit so I played around with just that
> one and it (itanium running hpux w/ broadcom gigabit) can push the load
> as well.  One weird thing is that it is dependent on the direction the
> data is flowing.  If the hp is sending then I get 46MB/sec, if linux is
> sending then I get 18MB/sec.  Weird.  Linux is debian, running 

First of all check the CPU load on both sides to see if either
of them is saturating.  If the CPU's fine then look at the tcpdump
output to see if both receivers are using the same window settings.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
