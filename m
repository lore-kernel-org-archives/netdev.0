From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Sat, 25 Jul 2009 13:04:09 +0200
Message-ID: <20090725110409.GA3086@ami.dom.local>
References: <20090720074607.32463.23013.sendpatchset@localhost.localdomain> <20090724083006.GA5698@ff.dom.local> <20090724083749.GA23521@gondor.apana.org.au> <OFFA0E0F2C.B17AF73A-ON652575FD.00372349-652575FD.0039CB03@in.ibm.com> <20090725032436.GA30741@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:61485 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751088AbZGYLEW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jul 2009 07:04:22 -0400
Received: by fxm18 with SMTP id 18so1834080fxm.37
        for <netdev@vger.kernel.org>; Sat, 25 Jul 2009 04:04:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090725032436.GA30741@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 25, 2009 at 11:24:36AM +0800, Herbert Xu wrote:
...
> However, I am definitely with you in that we should perform this
> optimisation since it makes sense for the majority of people who
> use multiqueue TX.
> 
> So the fact that our current architecture penalises the people
> who actually need multiqueue TX in order to ensure correctness
> for the people who cannot use multiqueue TX effectively (i.e.,
> those who use non-default qdiscs) makes me uneasy.

It would be nice to establish what difference is made by each part of
this patch. The check for stopped queue before each skb xmit was done
earlier too, so it's not exactly multiqueue penalization.

Cheers,
Jarek P.
