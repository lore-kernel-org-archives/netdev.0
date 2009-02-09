From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] addition of a dropped packet notification service
Date: Mon, 9 Feb 2009 21:21:34 +1100
Message-ID: <20090209102134.GA8492@gondor.apana.org.au>
References: <20090206182020.GA24399@hmsreliant.think-freely.org> <20090206165736.295ec007@extreme> <20090207174931.GA10247@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58102 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752351AbZBIKVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 05:21:48 -0500
Content-Disposition: inline
In-Reply-To: <20090207174931.GA10247@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 07, 2009 at 12:49:32PM -0500, Neil Horman wrote:
>
> Well, as I mentioned, its totally incomplete.  I only posted it, so that you
> could see an exemplar of how I wanted to use tracepoints to dynamically
> intercept various in kernel events so that I could gather drop notifications. Of
> course several other tracepoints will be needed to capture other classes of drop
> (IPv6 stats, arp queue overflows, qdisc drops, etc).

FWIW it sounds pretty reasonable to me.  Although I'm still unsure
on what impact all these trace points will have on the maintainence
of our source code.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
