From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: + oops-in-drivers-net-shaperc.patch added to -mm tree
Date: Sat, 27 Jan 2007 12:01:46 +1100
Message-ID: <20070127010146.GA18851@gondor.apana.org.au>
References: <20070125.193128.39155864.davem@davemloft.net> <E1HAbgn-00039h-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, akpm@osdl.org, deweerdt@free.fr,
	netdev@vger.kernel.org, frederik.deweerdt@gmail.com,
	shemminger@osdl.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4382 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751828AbXA0BBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jan 2007 20:01:53 -0500
Content-Disposition: inline
In-Reply-To: <E1HAbgn-00039h-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 27, 2007 at 11:45:05AM +1100, Herbert Xu wrote:
> David Miller <davem@davemloft.net> wrote:
> > 
> > Shaper is actually OK.  None of these hardware header callbacks
> > should be invoked if the device is down.  Yet, this is what is
> > accidently being allowed in the AF_PACKET socket layer.
> 
> Hmm, what if the device goes down after the check?

In fact, the shaper device doesn't even seem to take a ref count of
the device it has attached to.  So that device can go away at any time.
What's more, there are drivers that can change hard_header at run-time
(s390).

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
