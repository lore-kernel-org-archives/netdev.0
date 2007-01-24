From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2.6.20-rc5] IPV6: skb is unexpectedly freed.
Date: Wed, 24 Jan 2007 13:37:25 +0900 (JST)
Message-ID: <20070124.133725.07735362.yoshfuji@linux-ipv6.org>
References: <45B6C13E.1050204@ncos.nec.co.jp>
	<E1H9ZnX-0001z5-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nakagawa.msy@ncos.nec.co.jp, netdev@vger.kernel.org,
	mhuth@mvista.com, yoshfuji@linux-ipv6.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:46570 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965638AbXAXEgO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 23:36:14 -0500
In-Reply-To: <E1H9ZnX-0001z5-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <E1H9ZnX-0001z5-00@gondolin.me.apana.org.au> (at Wed, 24 Jan 2007 15:31:47 +1100), Herbert Xu <herbert@gondor.apana.org.au> says:

> Masayuki Nakagawa <nakagawa.msy@ncos.nec.co.jp> wrote:
> > 
> > I suggest to use kfree_skb() instead of __kfree_skb().
> 
> I agree.  In fact please do it for all paths in that function, i.e.,
> just change __kfree_skb to kfree_skb rather than adding a special case
> for this path.

I do think so, too.

--yoshfuji
