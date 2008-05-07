From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC/RFT 3/4] mac80211: use GSO for fragmentation
Date: Wed, 7 May 2008 17:00:40 +0800
Message-ID: <20080507090040.GA25186@gondor.apana.org.au>
References: <20080430124055.091382000@sipsolutions.net> <20080430130050.105344000@sipsolutions.net> <20080507071026.GA24407@gondor.apana.org.au> <1210150217.9305.39.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Ron Rindjunsky <ron.rindjunsky@intel.com>,
	Tomas Winkler <tomasw@gmail.com>,
	Ivo van Doorn <ivdoorn@gmail.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33689 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751699AbYEGJAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 05:00:44 -0400
Content-Disposition: inline
In-Reply-To: <1210150217.9305.39.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 07, 2008 at 10:50:17AM +0200, Johannes Berg wrote:
>
> But you're right, it doesn't work this way. I'll have to think of
> something. Maybe I can rip out all the retry logic and just store an skb
> myself (like dev->gso_skb) and return NETDEV_TX_BUSY when I used that
> one and the queue got full because of it. That'll requeue a lot when
> non-gso skbs are coming in, but mind you this is not a common case, most
> of the time fragmentation will not be enabled and even when it is device
> queues should be long enough.

Yes keeping your own gso_skb sounds like a good solution.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
