From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] sendfile() and UDP socket
Date: Tue, 23 Sep 2008 15:01:33 +0800
Message-ID: <20080923070133.GB26836@gondor.apana.org.au>
References: <20080922070425.GA14572@2ka.mipt.ru> <E1Khzut-0006lv-Co@gondolin.me.apana.org.au> <20080923062709.GA7886@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, johaahn@gmail.com, netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49667 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751972AbYIWHBl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 03:01:41 -0400
Content-Disposition: inline
In-Reply-To: <20080923062709.GA7886@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 23, 2008 at 10:27:10AM +0400, Evgeniy Polyakov wrote:
> On Tue, Sep 23, 2008 at 12:54:27PM +0800, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> > I think this dicussion is moot since the only time you want to use
> > sendfile is for bulk transfers and these days anybody designing new
> > applications that does bulk transfers over UDP should be taken out
> > and shot.
> 
> One can protect himself pointing how slow may be memory bus in some
> hardware setup, which completely does not allow to perform any copy.

Yes but bulk transfers over UDP is a bad idea regardless of how
slow your bus is :)

So what application needs this?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
