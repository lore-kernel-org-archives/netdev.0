From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.20-rc5] IPV6: skb is unexpectedly freed.
Date: Tue, 23 Jan 2007 20:40:08 -0800 (PST)
Message-ID: <20070123.204008.59666972.davem@davemloft.net>
References: <45B6C13E.1050204@ncos.nec.co.jp>
	<E1H9ZnX-0001z5-00@gondolin.me.apana.org.au>
	<20070124.133725.07735362.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, nakagawa.msy@ncos.nec.co.jp,
	netdev@vger.kernel.org, mhuth@mvista.com
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41500
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965641AbXAXEkF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 23:40:05 -0500
In-Reply-To: <20070124.133725.07735362.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Wed, 24 Jan 2007 13:37:25 +0900 (JST)

> In article <E1H9ZnX-0001z5-00@gondolin.me.apana.org.au> (at Wed, 24 Jan 2007 15:31:47 +1100), Herbert Xu <herbert@gondor.apana.org.au> says:
> 
> > Masayuki Nakagawa <nakagawa.msy@ncos.nec.co.jp> wrote:
> > > 
> > > I suggest to use kfree_skb() instead of __kfree_skb().
> > 
> > I agree.  In fact please do it for all paths in that function, i.e.,
> > just change __kfree_skb to kfree_skb rather than adding a special case
> > for this path.
> 
> I do think so, too.

So do I, but initially I want to push his basic patch in
so that I can push the same exact thing into -stable to
fix this bug.

So if you make the subsequent change, please make it relative
to the original patch.

Thank you.
