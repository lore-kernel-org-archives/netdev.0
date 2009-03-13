From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC v2: Patch 1/3] net: hand off skb list to other cpu to
	submit to upper layer
Date: Sat, 14 Mar 2009 07:58:15 +0800
Message-ID: <20090313235815.GA2713@gondor.apana.org.au>
References: <65634d660903131358h765bef64y6a0f1b0db7400f6f@mail.gmail.com> <20090313.140217.143696945.davem@davemloft.net> <65634d660903131459m645eb468y3ad850a1fd56d447@mail.gmail.com> <20090313.151913.21135937.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: therbert@google.com, yanmin_zhang@linux.intel.com,
	bhutchings@solarflare.com, andi@firstfloor.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jesse.brandeburg@intel.com, shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:56636 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751659AbZCMX6d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 19:58:33 -0400
Content-Disposition: inline
In-Reply-To: <20090313.151913.21135937.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 13, 2009 at 03:19:13PM -0700, David Miller wrote:
> 
> > improvement in packets per second across both our dumb 1G and 10G
> > NICs
> 
> Do these NICs at least support multiqueue?

I don't think they do.  See the lsat paragraph in Tom's first
email.

I think we all agree that hacks such as these are onlhy useful
for NICs that either don't support mq or if the number of rx
queues is too small.

The question is how much do we love these NICs :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
