From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] sctp/tcp: Question -- ICMPv4 length check (not) redundant?
Date: Sun, 27 Jul 2008 12:51:21 +0800
Message-ID: <20080727045121.GA419@gondor.apana.org.au>
References: <20080726.003617.265743493.davem@davemloft.net> <E1KMyB1-00006Y-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gerrit@erg.abdn.ac.uk, vladislav.yasevich@hp.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:51545 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753015AbYG0Eva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jul 2008 00:51:30 -0400
Content-Disposition: inline
In-Reply-To: <E1KMyB1-00006Y-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 27, 2008 at 12:48:11PM +0800, Herbert Xu wrote:
> David Miller <davem@davemloft.net> wrote:
> >
> > What if the lower protocol doesn't have a header that it
> > at least 8 bytes? :-)
> 
> When such a protocol enters our tree then we can undo this patch :)

OK I take that back as IPComp is only 4 bytes long :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
