From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Kernel problem
Date: Thu, 26 Feb 2009 19:56:04 +0800
Message-ID: <20090226115604.GA13592@gondor.apana.org.au>
References: <20090226093902.GA12753@gondor.apana.org.au> <20090226105616.GA5754@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denis Romanenko <ash@sevsky.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59376 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754327AbZBZL4O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 06:56:14 -0500
Content-Disposition: inline
In-Reply-To: <20090226105616.GA5754@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 26, 2009 at 10:56:16AM +0000, Jarek Poplawski wrote:
> 
> netconsole. It's a known issue, btw.

I see.  So the problem in this case appears to be that we're
processing incoming packets in netpoll_poll.  So the obvious
question can we just not do that since all we need to do is
transmit packets?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
