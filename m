From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/2] Disable forwarding of LRO skbs
Date: Thu, 1 May 2008 22:06:25 +0800
Message-ID: <20080501140625.GA9055@gondor.apana.org.au>
References: <20080430214845.GC14219@solarflare.com> <E1JrWFU-0001ue-00@gondolin.me.apana.org.au> <20080501110225.GG14219@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kmansley@solarflare.com,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53359 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752485AbYEAOGg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 10:06:36 -0400
Content-Disposition: inline
In-Reply-To: <20080501110225.GG14219@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 01, 2008 at 12:02:27PM +0100, Ben Hutchings wrote:
>
> My understanding is that at the points I'm adding the check, we're only
> considering received skbs and gso_size will only be set if LRO was used.

Unfortunately that's not the case.  The forwarding path can and
does occur for GSO packets sent from other guests.  The obvious
case would be a GSO packet from a guest forwarded by the host
(as opposed to bridged) to the outside world.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
