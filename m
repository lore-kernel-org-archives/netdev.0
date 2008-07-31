From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: using software TSO on non-TSO capable netdevices
Date: Thu, 31 Jul 2008 11:03:39 +0800
Message-ID: <20080731030339.GA4327@gondor.apana.org.au>
References: <20080731004123.GB22826@xi.wantstofly.org> <E1KONuu-00017h-00@gondolin.me.apana.org.au> <20080731023652.GA23814@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, akarkare@marvell.com,
	nico@cam.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:46200 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757017AbYGaDDr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 23:03:47 -0400
Content-Disposition: inline
In-Reply-To: <20080731023652.GA23814@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 31, 2008 at 04:36:52AM +0200, Lennert Buytenhek wrote:
>
> The maximum that splice will allow -- PIPE_BUFFERS * PAGE_SIZE.
> 
> I.e. the writes should be large enough.

Have you looked at the packet dump? Maybe it was being constrained
by the receiver/congestion windows.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
