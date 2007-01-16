From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: rare bad TCP checksum with 2.6.19?
Date: Tue, 16 Jan 2007 14:27:39 +1100
Message-ID: <20070116032739.GA12746@gondor.apana.org.au>
References: <E1H6OJU-0001EC-00@gondolin.me.apana.org.au> <45AB82F1.9000409@tls.msk.ru> <20070115201001.GA9510@gondor.apana.org.au> <45ABF620.3070405@tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3096 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932067AbXAPD1m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jan 2007 22:27:42 -0500
To: Michael Tokarev <mjt@tls.msk.ru>
Content-Disposition: inline
In-Reply-To: <45ABF620.3070405@tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 16, 2007 at 12:46:08AM +0300, Michael Tokarev wrote:
> 
> The trace is here: http://www.corpit.ru/mjt/bad-tcp-cksum-dmp.bin

I'm sorry but this dump does NOT look like it was taken from an
intermediate box.  I verified two bad checksums (chosen randomly)
and they were both correct but partial checksums.  This means that
this dump was most likely taken from the sending host.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
