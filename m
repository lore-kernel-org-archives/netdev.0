From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: mac80211 truesize bugs
Date: Sat, 3 May 2008 20:59:40 +0800
Message-ID: <20080503125940.GA26199@gondor.apana.org.au>
References: <20080501.024320.212547875.davem@davemloft.net> <E1JrW9h-0001tI-00@gondolin.me.apana.org.au> <20080501.034950.261408566.davem@davemloft.net> <20080501.035335.216935614.davem@davemloft.net> <1209639500.7067.0.camel@johannes.berg> <20080501110341.GD7490@gondor.apana.org.au> <1209818282.3987.23.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, mb@bu3sch.de,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:56671 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752035AbYECM7x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 May 2008 08:59:53 -0400
Content-Disposition: inline
In-Reply-To: <1209818282.3987.23.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 03, 2008 at 02:38:01PM +0200, Johannes Berg wrote:
>
> Why, btw? It's not too hard to check the allocated size, no?

Yes that would be a meaningful improvement although we'd need to
audit/test this to make sure that we don't spam people's logs
with it.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
