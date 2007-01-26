From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH] TCP: Replace __kfree_skb() with kfree_skb()
Date: Fri, 26 Jan 2007 17:19:32 +0300
Message-ID: <20070126141932.GA627@ms2.inr.ac.ru>
References: <45B97763.8000305@ncos.nec.co.jp> <20070126082838.GA1639@ff.dom.local> <20070126091606.GA23469@gondor.apana.org.au> <20070126094950.GB1639@ff.dom.local> <20070126095251.GA24204@gondor.apana.org.au> <20070126101838.GC1639@ff.dom.local> <20070126104518.GA24490@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarek Poplawski <jarkao2@o2.pl>,
	Masayuki Nakagawa <nakagawa.msy@ncos.nec.co.jp>,
	davem@davemloft.net, yoshfuji@linux-ipv6.org, mhuth@mvista.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:53663 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1030226AbXAZOVJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jan 2007 09:21:09 -0500
Content-Disposition: inline
In-Reply-To: <20070126104518.GA24490@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> do you know of any place where __kfree_skb is used to free an skb
> whose ref count is greater than 1?

No.

Actually, since kfree_skb is not inline, __kfree_skb could be made static
and remaining places still using it switched to kfree_skb.






