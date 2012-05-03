From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: implement tcp coalescing in
 tcp_queue_rcv()
Date: Wed, 02 May 2012 21:11:57 -0400 (EDT)
Message-ID: <20120502.211157.2201073892985382154.davem@davemloft.net>
References: <1335977179.22133.599.camel@edumazet-glaptop>
	<1335981358.22133.605.camel@edumazet-glaptop>
	<1335988709.22133.632.camel@edumazet-glaptop>
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
Received: from shards.monkeyblade.net ([198.137.202.13]:38368 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752849Ab2ECBMN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 21:12:13 -0400
In-Reply-To: <1335988709.22133.632.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 02 May 2012 21:58:29 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Extend tcp coalescing implementing it from tcp_queue_rcv(), the main
> receiver function when application is not blocked in recvmsg().
> 
> Function tcp_queue_rcv() is moved a bit to allow its call from
> tcp_data_queue()
> 
> This gives good results especially if GRO could not kick, and if skb
> head is a fragment.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
