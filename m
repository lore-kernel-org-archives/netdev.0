From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: implement tcp coalescing in
 tcp_queue_rcv()
Date: Wed, 02 May 2012 22:21:46 -0400 (EDT)
Message-ID: <20120502.222146.1074440914668198833.davem@davemloft.net>
References: <1335988709.22133.632.camel@edumazet-glaptop>
	<20120502.211157.2201073892985382154.davem@davemloft.net>
	<1336011260.22133.754.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.duyck@gmail.com, alexander.h.duyck@intel.com,
	netdev@vger.kernel.org, ncardwell@google.com, therbert@google.com,
	jeffrey.t.kirsher@intel.com, mchan@broadcom.com,
	mcarlson@broadcom.com, herbert@gondor.hengli.com.au,
	bhutchings@solarflare.com, ilpo.jarvinen@helsinki.fi,
	maze@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38822 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753779Ab2ECCWG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 22:22:06 -0400
In-Reply-To: <1336011260.22133.754.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 May 2012 04:14:20 +0200

> My next step is to provide a common helper to NAPI drivers to replace 
> netdev_alloc_skb_ip_align(struct net_device *dev, unsigned int len)
> 
> by :
> 
> struct sk_buff *napi_alloc_rxskb(struct napi_struct *napi, unsigned int len)
> 
> That will manage a cache of one page, splitted in fragments as needed.
> (roughly the code we added in tg3 as POC)
> 
> Because converting drivers to build_skb() is a too slow process.

Sounds good.
