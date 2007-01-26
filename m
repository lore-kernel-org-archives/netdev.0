From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] TCP: Replace __kfree_skb() with kfree_skb()
Date: Fri, 26 Jan 2007 12:02:35 +0100
Message-ID: <20070126110235.GD1639@ff.dom.local>
References: <45B97763.8000305@ncos.nec.co.jp> <20070126082838.GA1639@ff.dom.local> <20070126091606.GA23469@gondor.apana.org.au> <20070126094950.GB1639@ff.dom.local> <20070126095251.GA24204@gondor.apana.org.au> <20070126101838.GC1639@ff.dom.local> <20070126104518.GA24490@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Masayuki Nakagawa <nakagawa.msy@ncos.nec.co.jp>,
	davem@davemloft.net, yoshfuji@linux-ipv6.org, mhuth@mvista.com,
	netdev@vger.kernel.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:40956 "EHLO poczta.o2.pl"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932873AbXAZLAG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jan 2007 06:00:06 -0500
Content-Disposition: inline
In-Reply-To: <20070126104518.GA24490@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 26, 2007 at 09:45:18PM +1100, Herbert Xu wrote:
> On Fri, Jan 26, 2007 at 11:18:38AM +0100, Jarek Poplawski wrote:
> > 
> > I don't mean it's necessary. I mean now skb is freed
> > unconditionally and after this patch, if there is some
> > error in counting, skb will stay. I thought Masayuki
> > wrote about such possibility, but if I missed his
> > point, then the rest is really O.K.
> 
> OK, I see what you mean.
> 
> I'm not aware of anybody who has coded in this way.  Alexey & Dave,
> do you know of any place where __kfree_skb is used to free an skb
> whose ref count is greater than 1?

I'm sure it wasn't done on purpose! But it could hide
some errors anyway.

Jarek P.
