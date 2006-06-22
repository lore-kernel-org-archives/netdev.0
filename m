From: David Miller <davem@davemloft.net>
Subject: Re: [1/5] [NET]: Merge TSO/UFO fields in sk_buff
Date: Wed, 21 Jun 2006 18:14:34 -0700 (PDT)
Message-ID: <20060621.181434.02298785.davem@davemloft.net>
References: <20060621232741.GA21559@gondor.apana.org.au>
	<1150937184.4069.4.camel@rh4>
	<20060622010925.GA22448@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:45451
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030473AbWFVBOT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jun 2006 21:14:19 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060622010925.GA22448@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 22 Jun 2006 11:09:25 +1000

> ECE just needs to be replicated so it would seem to be a safe bet unless
> Dave knows some really broken hardware out there? If not I'd say that
> we should just assume that it works and add a new bit it if said broken
> stuff does turn up.

ECE simply needs to persist while the ECE condition is true.
If it is true when we build the TSO frame, it would have
thus been true during the time in which we had built each
individual sub-frame.

I don't anticipate any problems if you just mirror the ECE
bit in each chopped up frame.

> Thanks a lot for looking into this!

Yes, indeed, thanks Michael.
