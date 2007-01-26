From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TCP: Replace __kfree_skb() with kfree_skb()
Date: Fri, 26 Jan 2007 02:58:32 -0800 (PST)
Message-ID: <20070126.025832.74749578.davem@davemloft.net>
References: <20070126095251.GA24204@gondor.apana.org.au>
	<20070126101838.GC1639@ff.dom.local>
	<20070126104518.GA24490@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@o2.pl, nakagawa.msy@ncos.nec.co.jp,
	yoshfuji@linux-ipv6.org, mhuth@mvista.com, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33724
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932846AbXAZK6d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jan 2007 05:58:33 -0500
In-Reply-To: <20070126104518.GA24490@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 26 Jan 2007 21:45:18 +1100

> I'm not aware of anybody who has coded in this way.  Alexey & Dave,
> do you know of any place where __kfree_skb is used to free an skb
> whose ref count is greater than 1?

Not at all.
