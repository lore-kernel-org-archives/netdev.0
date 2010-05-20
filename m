From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tun: Use netif_receive_skb instead of netif_rx
Date: Fri, 21 May 2010 09:16:30 +1000
Message-ID: <20100520231630.GA22593@gondor.apana.org.au>
References: <4BF4517F.1010206@athenacr.com> <20100519.195533.22536631.davem@davemloft.net> <20100520025741.GA6129@gondor.apana.org.au> <20100519.200522.140743640.davem@davemloft.net> <20100520033446.GA6434@gondor.apana.org.au> <1274332507.2658.31.camel@edumazet-laptop> <20100520052059.GC7443@gondor.apana.org.au> <1274333779.2658.43.camel@edumazet-laptop> <20100520054642.GA7836@gondor.apana.org.au> <20100520172918.GA17613@shamino.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, bmb@athenacr.com,
	tgraf@redhat.com, nhorman@redhat.com, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:58368 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754816Ab0ETXQt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 May 2010 19:16:49 -0400
Content-Disposition: inline
In-Reply-To: <20100520172918.GA17613@shamino.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 20, 2010 at 01:29:18PM -0400, Neil Horman wrote:
>
> So, I'm testing this patch out now, and unfotunately it doesn't seem to be
> working.  Every frame seems to be holding a classid of 0.  Trying to figure out
> why now.

Not very surprising since tun.c doesn't go through the normal
socket interface.  I'll send a additional patch for that.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
