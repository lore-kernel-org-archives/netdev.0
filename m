From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: why would EPIPE cause socket port to change?
Date: Tue, 23 Jan 2007 22:18:58 +1100
Message-ID: <20070123111858.GA29425@gondor.apana.org.au>
References: <E1H9ES2-0006uJ-00@gondolin.me.apana.org.au> <45B5ED2F.7020303@tls.msk.ru> <20070123111225.GA29349@gondor.apana.org.au> <45B5EE61.7010507@tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dean gaudet <dean@arctic.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3661 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932971AbXAWLTE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 06:19:04 -0500
To: Michael Tokarev <mjt@tls.msk.ru>
Content-Disposition: inline
In-Reply-To: <45B5EE61.7010507@tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 23, 2007 at 02:15:45PM +0300, Michael Tokarev wrote:
> 
> Still, after the connection has been closed, there's no chance to do
> anything with the filedescriptor but to close it as well, right?  Or
> can the fd be reused by making new connection with it, as if it were
> just returned from socket() call?

Yes you can connect out on it again if you're in TCP_CLOSE.  The fact
that the port number has changed implies that you've entered TCP_CLOSE.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
