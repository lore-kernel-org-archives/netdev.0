From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/3] [UDP]: Restore missing inDatagrams increments
Date: Wed, 5 Dec 2007 20:54:53 +1100
Message-ID: <20071205095453.GA17410@gondor.apana.org.au>
References: <20071204130109.GA3098@gondor.apana.org.au> <47560215.6050104@cn.fujitsu.com> <20071205021559.GA27707@gondor.apana.org.au> <20071205.015301.87202109.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: wangchen@cn.fujitsu.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1319 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751464AbXLEJy5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 04:54:57 -0500
Content-Disposition: inline
In-Reply-To: <20071205.015301.87202109.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 05, 2007 at 01:53:01AM -0800, David Miller wrote:
>
> > [UDP]: Restore missing inDatagrams increments
> >     
> > The previous move of the the UDP inDatagrams counter caused the
> > counting of encapsulated packets, SUNRPC data (as opposed to call)
> > packets and RXRPC packets to go missing.
> >     
> > This patch restores all of these.
> > 
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Applied.

Sorry, Eric spotted a build problem in my patch.  So you'll need to
replace this with the fixed version that I sent literally minutes ago :)

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
