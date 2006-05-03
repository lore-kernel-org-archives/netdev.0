From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Disabling "TCP Treason uncloaked"
Date: Wed, 3 May 2006 22:21:10 +1000
Message-ID: <20060503122110.GA1675@gondor.apana.org.au>
References: <E1FbBPy-0007Iu-00@gondolin.me.apana.org.au> <200605031347.31281.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Just Marc <marc@corky.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58641 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S965179AbWECMVO
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 May 2006 08:21:14 -0400
To: Ingo Oeser <netdev@axxeo.de>
Content-Disposition: inline
In-Reply-To: <200605031347.31281.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 03, 2006 at 01:47:31PM +0200, Ingo Oeser wrote:
> 
> Already there: /proc/sys/net/core/{message_cost,message_burst}
> 
> Just set burst to 0 and cost to a very big value to basically supppress
> all net_ratelimit()ed messages.
> 
> Or did you think of sth. else?

No that'll do just fine.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
