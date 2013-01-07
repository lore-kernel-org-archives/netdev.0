From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC PATCH 0/3] Make rfc3686 template work with asynchronous
 block ciphers
Date: Mon, 7 Jan 2013 08:00:36 +0100
Message-ID: <20130107070036.GP18940@secunet.com>
References: <20121228100448.11073.25546.stgit@localhost6.localdomain6>
 <20121228224248.GA29448@gondor.apana.org.au>
 <20121228.152311.290755667605168896.davem@davemloft.net>
 <20121229000812.GA29866@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jussi.kivilinna@mbnet.fi,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:48802 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751068Ab3AGHAk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jan 2013 02:00:40 -0500
Content-Disposition: inline
In-Reply-To: <20121229000812.GA29866@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 29, 2012 at 11:08:12AM +1100, Herbert Xu wrote:
> On Fri, Dec 28, 2012 at 03:23:11PM -0800, David Miller wrote:
> > From: Herbert Xu <herbert@gondor.apana.org.au>
> > Date: Sat, 29 Dec 2012 09:42:49 +1100
> > 
> > > On Fri, Dec 28, 2012 at 12:04:48PM +0200, Jussi Kivilinna wrote:
> > >> I'm not sure how this patchset should be dealt with (should 1st patch go
> > >> through different tree than 2nd and 3rd?), so therefore it's RFC.
> > >> 
> > >> Second patch makes rfc3686 template work with asynchronous block ciphers and
> > >> third patch changes aesni-intel to use this template. First patch fixed problem
> > >> in xfrm_algo found with help of 2nd and 3rd patches and without 1st patch
> > >> 2nd patch breaks aes-ctr with IPSEC.
> > > 
> > > I think the easiest way is to have these patches go through Dave's
> > > tree.
> > 
> > Better yet, Steffen's IPSEC tree :-)
> 
> Of course :)

Herbert, can I add your Ack to the crypto patches?
