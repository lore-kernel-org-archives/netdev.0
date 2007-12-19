From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: "ip neigh show" not showing arp cache entries?
Date: Wed, 19 Dec 2007 09:14:01 +0800
Message-ID: <20071219011401.GA4585@gondor.apana.org.au>
References: <E1J4TCz-0005L8-00@gondolin.me.apana.org.au> <4767DE91.9060803@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yoshfuji@linux-ipv6.org, dada1@cosmosbay.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1297 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753250AbXLSBOJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2007 20:14:09 -0500
Content-Disposition: inline
In-Reply-To: <4767DE91.9060803@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 18, 2007 at 08:52:01AM -0600, Chris Friesen wrote:
>
> Looks like that did it.  Why does specifying the family make a difference?

Because this is the only parameter that changes kernel behaviour.

Next step is to strace both commands with -s 16384 to see exactly
what the kernel reply looks like to determine the problem.

BTW my emails to you are bouncing so you might want to fix that.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
