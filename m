From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Remove notifier block from chain when register_netdevice_notifier fails
Date: Wed, 14 Nov 2007 21:50:55 +0800
Message-ID: <20071114135055.GA14982@gondor.apana.org.au>
References: <473AE523.70501@openvz.org> <20071114133717.GA14746@gondor.apana.org.au> <473AFC6C.6000505@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2792 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754197AbXKNNu6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 08:50:58 -0500
Content-Disposition: inline
In-Reply-To: <473AFC6C.6000505@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 14, 2007 at 04:47:24PM +0300, Pavel Emelyanov wrote:
>
> BTW, I have one more question I can't find the answer to by 
> myself. Why the unregister_netdevice_notifier doesn't produce 
> the GOING_DOWN-DOWN-UNREGISTER event sequence for the notifier
> block which is being unregistered? Was this made deliberately?

I think it's more of an oversight :)

Although it has no real impact because the only user that matters
here is IPv6 and it can't be unloaded.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
