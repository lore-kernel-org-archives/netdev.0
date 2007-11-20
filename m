From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] LRO ack aggregation
Date: Tue, 20 Nov 2007 22:08:31 +0800
Message-ID: <20071120140831.GA18465@gondor.apana.org.au>
References: <E1IuMIQ-0003gc-00@gondolin.me.apana.org.au> <20071119.222214.81458569.davem@davemloft.net> <4742C96D.3050203@myri.com> <20071120.035558.214794900.davem@davemloft.net> <4742E0A9.2070205@myri.com> <20071120133509.GA17377@2ka.mipt.ru> <20071120135056.GA18266@gondor.apana.org.au> <20071120140312.GA6695@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Gallatin <gallatin@myri.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	ossthema@de.ibm.com
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4070 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752458AbXKTOIi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 09:08:38 -0500
Content-Disposition: inline
In-Reply-To: <20071120140312.GA6695@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 20, 2007 at 05:03:12PM +0300, Evgeniy Polyakov wrote:
> 
> For software lro I agree, but this looks exactly like gso/tso case and
> additional tweak for software gso. Having it per-system is fine, and I
> believe no one should ever care that some distro will do bad/good things
> with it. Actually we do have so much tricky options in procfs already
> which can kill performance...

Right, if you're doing it such that the same option automatically
shows up for every driver that uses software LRO then my second
concern goes away.

Of course we still have the problem with the option in general
that Dave raised.  That is this may cause the proliferation of
TCP receiver behaviour that may be undesirable.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
