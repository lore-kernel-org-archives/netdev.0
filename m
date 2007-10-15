From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] [IPV6]: Avoid
 skb_copy/pskb_copy/skb_realloc_headroom on input
Date: Mon, 15 Oct 2007 01:29:17 -0700 (PDT)
Message-ID: <20071015.012917.03996009.davem@davemloft.net>
References: <20071014144649.GA14792@gondor.apana.org.au>
	<E1Ih4m8-0003rz-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, hadi@cyberus.ca, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, tgraf@suug.ch
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55581
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757239AbXJOI3N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 04:29:13 -0400
In-Reply-To: <E1Ih4m8-0003rz-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 14 Oct 2007 22:49:04 +0800

> [IPV6]: Avoid skb_copy/pskb_copy/skb_realloc_headroom on input
> 
> This patch replaces unnecessary uses of skb_copy by pskb_expand_head
> on the IPv6 input path.
> 
> This allows us to remove the double pointers later.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
