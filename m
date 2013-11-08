From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v4 net-next] net: introduce dev_set_forwarding()
Date: Fri, 8 Nov 2013 12:10:16 +0800
Message-ID: <20131108041016.GB14325@gondor.apana.org.au>
References: <1383584130.1553.2.camel@bwh-desktop.uk.level5networks.com>
 <20131107.161755.355597965034457889.davem@davemloft.net>
 <20131107213111.GA6885@gondor.apana.org.au>
 <20131107.170651.1819930710384730745.davem@davemloft.net>
 <20131108021758.GA13467@gondor.apana.org.au>
 <1383878554.9412.153.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131108032208.GA14056@gondor.apana.org.au>
 <1383883594.9412.158.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:47042 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752779Ab3KHEK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 23:10:26 -0500
Content-Disposition: inline
In-Reply-To: <1383883594.9412.158.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 07, 2013 at 08:06:34PM -0800, Eric Dumazet wrote:
> On Fri, 2013-11-08 at 11:22 +0800, Herbert Xu wrote:
> 
> > If it really hurt then they can always turn it off using ethtool.
> > With your patch that automatically turns it off virt folks have
> > no way of even turning it on.
> 
> Let me remind you that before the GRO frag_list patch, virt folks had no
> choice anyway. GRO packets were limited to 16 MSS.
> 
> Its not because we can build large packets that we must do so.
> 
> This was an error of our TSO implementation.

Well you still don't seem to be getting this: If you need it for
the host then you will need it even more for virt because the
network stack there is much longer.

So having it only available to the host without also giving it
to virt makes *zero* sense.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
