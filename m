From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: why would EPIPE cause socket port to change?
Date: Tue, 23 Jan 2007 22:12:25 +1100
Message-ID: <20070123111225.GA29349@gondor.apana.org.au>
References: <E1H9ES2-0006uJ-00@gondolin.me.apana.org.au> <45B5ED2F.7020303@tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dean gaudet <dean@arctic.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3623 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932899AbXAWLMg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 06:12:36 -0500
To: Michael Tokarev <mjt@tls.msk.ru>
Content-Disposition: inline
In-Reply-To: <45B5ED2F.7020303@tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 23, 2007 at 02:10:39PM +0300, Michael Tokarev wrote:
> 
> Well, but why getsockname() didn't just return ENOTCONN?

It's perfectly valid to have a local port number without being connected.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
