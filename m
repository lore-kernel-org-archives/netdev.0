From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] TCP: Replace __kfree_skb() with kfree_skb()
Date: Fri, 26 Jan 2007 14:18:08 +0100
Message-ID: <20070126131808.GE1639@ff.dom.local>
References: <45B97763.8000305@ncos.nec.co.jp> <20070126082838.GA1639@ff.dom.local> <20070126091606.GA23469@gondor.apana.org.au> <20070126094950.GB1639@ff.dom.local> <20070126095251.GA24204@gondor.apana.org.au> <20070126101838.GC1639@ff.dom.local> <20070126104518.GA24490@gondor.apana.org.au> <20070126110235.GD1639@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Masayuki Nakagawa <nakagawa.msy@ncos.nec.co.jp>,
	davem@davemloft.net, yoshfuji@linux-ipv6.org, mhuth@mvista.com,
	netdev@vger.kernel.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:33469 "EHLO poczta.o2.pl"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S965619AbXAZNPm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jan 2007 08:15:42 -0500
Content-Disposition: inline
In-Reply-To: <20070126110235.GD1639@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 26, 2007 at 12:02:35PM +0100, Jarek Poplawski wrote:
> On Fri, Jan 26, 2007 at 09:45:18PM +1100, Herbert Xu wrote:
> > On Fri, Jan 26, 2007 at 11:18:38AM +0100, Jarek Poplawski wrote:
> > > 
> > > I don't mean it's necessary. I mean now skb is freed
> > > unconditionally and after this patch, if there is some
> > > error in counting, skb will stay. I thought Masayuki
> > > wrote about such possibility, but if I missed his
> > > point, then the rest is really O.K.
> > 
> > OK, I see what you mean.
> > 
> > I'm not aware of anybody who has coded in this way.  Alexey & Dave,
> > do you know of any place where __kfree_skb is used to free an skb
> > whose ref count is greater than 1?
> 
> I'm sure it wasn't done on purpose! But it could hide
> some errors anyway.

But not sure anymore...

I've only now read the original thread of this problem
and this long note about security. I need more time to
understand this, but now I'm not sure Masayuki's server
isn't doing something against the policy of this note
(at the first sight it looks like this kind of skb
isn't welcommed there).

So maybe I miss something, but there could be also
possibility this __kfree_skb prevents some errors in
a hard way - I'm not sure: on purpose or accidentally.

Have a lot of fun in the weekend,
Jarek P.
