From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PKT_SCHED]: Add stateless NAT
Date: Sun, 30 Sep 2007 07:36:53 +0800
Message-ID: <20070929233653.GA7319@gondor.apana.org.au>
References: <E1IbT8r-0000Av-00@gondolin.me.apana.org.au> <46FE6D73.4000002@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, hadi@cyberus.ca, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3729 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753309AbXI2Xh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Sep 2007 19:37:59 -0400
Content-Disposition: inline
In-Reply-To: <46FE6D73.4000002@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 29, 2007 at 05:21:23PM +0200, Patrick McHardy wrote:
>
> Unfortunately gcc doesn't perform tail call optimization when the
> address of a parameter or local variable is passed to an extern
> function before the tail call, which NF_HOOK does for the skb.

You mean the struct sk_buff **pskb bit? I've always wondered
why netfilter had to modify the skb.  Could we perhaps make it
so that it doesn't need to do so?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
