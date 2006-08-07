From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] SNMPv2 tcpOutSegs counter error
Date: Mon, 7 Aug 2006 12:48:50 +1000
Message-ID: <20060807024850.GA3446@gondor.apana.org.au>
References: <1154920659.3388.4.camel@LINE> <E1G9v2g-0000rZ-00@gondolin.me.apana.org.au> <20060806.194447.109339874.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yjwei@nanjing-fnst.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:23302 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750932AbWHGCs4
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Aug 2006 22:48:56 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060806.194447.109339874.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 06, 2006 at 07:44:47PM -0700, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Mon, 07 Aug 2006 12:40:34 +1000
> 
> > The general approach looks sound.  I have one esoteric question
> > though.  If a retransmitted packet is coalesced with one that is
> > yet to be transmitted (a fairly unlikely scenario, but possible I
> > think), should it count towards OUTSEGS?
> 
> Probably the packet should be counted to OUTSEGS if any of it contains
> new data.

OK, in that case Yongjun please update your patch to test against
tcb->end_seq instead of tcb->seq.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
