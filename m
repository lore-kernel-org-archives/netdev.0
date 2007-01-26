From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] TCP: Replace __kfree_skb() with kfree_skb()
Date: Fri, 26 Jan 2007 20:16:06 +1100
Message-ID: <20070126091606.GA23469@gondor.apana.org.au>
References: <45B97763.8000305@ncos.nec.co.jp> <20070126082838.GA1639@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Masayuki Nakagawa <nakagawa.msy@ncos.nec.co.jp>,
	davem@davemloft.net, yoshfuji@linux-ipv6.org, mhuth@mvista.com,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2783 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965577AbXAZJQd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jan 2007 04:16:33 -0500
Content-Disposition: inline
In-Reply-To: <20070126082838.GA1639@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 26, 2007 at 09:28:38AM +0100, Jarek Poplawski wrote:
> 
> So maybe for some time there should be added skb->users
> test with a warning to reveal this?

Or just replace __kfree_skb by kfree_skb.  The atomic operation (the
expensive part of kfree_skb vs. __kfree_skb) is only taken when it
is needed.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
