From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] TCP: Replace __kfree_skb() with kfree_skb()
Date: Fri, 26 Jan 2007 21:45:18 +1100
Message-ID: <20070126104518.GA24490@gondor.apana.org.au>
References: <45B97763.8000305@ncos.nec.co.jp> <20070126082838.GA1639@ff.dom.local> <20070126091606.GA23469@gondor.apana.org.au> <20070126094950.GB1639@ff.dom.local> <20070126095251.GA24204@gondor.apana.org.au> <20070126101838.GC1639@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Masayuki Nakagawa <nakagawa.msy@ncos.nec.co.jp>,
	davem@davemloft.net, yoshfuji@linux-ipv6.org, mhuth@mvista.com,
	netdev@vger.kernel.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3099 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932623AbXAZKpp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jan 2007 05:45:45 -0500
Content-Disposition: inline
In-Reply-To: <20070126101838.GC1639@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 26, 2007 at 11:18:38AM +0100, Jarek Poplawski wrote:
> 
> I don't mean it's necessary. I mean now skb is freed
> unconditionally and after this patch, if there is some
> error in counting, skb will stay. I thought Masayuki
> wrote about such possibility, but if I missed his
> point, then the rest is really O.K.

OK, I see what you mean.

I'm not aware of anybody who has coded in this way.  Alexey & Dave,
do you know of any place where __kfree_skb is used to free an skb
whose ref count is greater than 1?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
