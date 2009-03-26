From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.29 forcedeth hang W/O NAPI enabled
Date: Thu, 26 Mar 2009 14:58:25 +0800
Message-ID: <20090326065825.GA15730@gondor.apana.org.au>
References: <20090326033658.GA14592@gondor.apana.org.au> <985285.87214.qm@web57701.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, berkley@cs.wustl.edu
To: Adam Richter <adam_richter2004@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43326 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751294AbZCZG6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 02:58:34 -0400
Content-Disposition: inline
In-Reply-To: <985285.87214.qm@web57701.mail.re3.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 25, 2009 at 10:24:42PM -0700, Adam Richter wrote:
> 
> OK.  I tried your patch.  It seems fine.  I was able to do "ping -f" for five minutes with no problems, and surf the web during that time.

Thanks for testing! Since you also have a forcedeth card, could
you try rebuilding your kernel with FORCEDETH_NAPI enabled and
see if that is stable?

> I preserving the rest of your message below, just to be clear about which patch I tested.

Yep it's the right one.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
