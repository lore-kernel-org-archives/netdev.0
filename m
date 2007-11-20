From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] LRO ack aggregation
Date: Tue, 20 Nov 2007 21:50:56 +0800
Message-ID: <20071120135056.GA18266@gondor.apana.org.au>
References: <E1IuMIQ-0003gc-00@gondolin.me.apana.org.au> <20071119.222214.81458569.davem@davemloft.net> <4742C96D.3050203@myri.com> <20071120.035558.214794900.davem@davemloft.net> <4742E0A9.2070205@myri.com> <20071120133509.GA17377@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Gallatin <gallatin@myri.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	ossthema@de.ibm.com
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3953 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750823AbXKTNvR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 08:51:17 -0500
Content-Disposition: inline
In-Reply-To: <20071120133509.GA17377@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 20, 2007 at 04:35:09PM +0300, Evgeniy Polyakov wrote:
> 
> On Tue, Nov 20, 2007 at 08:27:05AM -0500, Andrew Gallatin (gallatin@myri.com) wrote:
> > Hmm.. rather than a global tunable, what if it was a
> > network driver managed tunable which toggled a flag in the
> > lro_mgr features?  Would that be better?
> 
> What about ethtool control to set LRO_simple and LRO_ACK_aggregation?

I have two concerns about this:

1) That same option can still be turned on by distros.
2) This doesn't make sense because the code is actually in the
   core networking stack.

I'm particular unhappy about 2) because I don't want be in a
situation down the track where every driver is going to add this
option so that they're not left behind in the arms race.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
