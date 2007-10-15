From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] [IPV6]: Make ipv6_frag_rcv return the same packet
Date: Mon, 15 Oct 2007 01:28:55 -0700 (PDT)
Message-ID: <20071015.012855.25458802.davem@davemloft.net>
References: <20071014144649.GA14792@gondor.apana.org.au>
	<E1Ih4m7-0003rk-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, hadi@cyberus.ca, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, tgraf@suug.ch
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38199
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751746AbXJOI2v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 04:28:51 -0400
In-Reply-To: <E1Ih4m7-0003rk-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 14 Oct 2007 22:49:03 +0800

> [IPV6]: Make ipv6_frag_rcv return the same packet
> 
> This patch implements the same change taht was done to ip_defrag.  It
> makes ipv6_frag_rcv return the last packet received of a train of fragments
> rather than the head of that sequence.
> 
> This allows us to get rid of the sk_buff ** argument later.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
