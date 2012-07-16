From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: respect GFP_DMA in __netdev_alloc_skb()
Date: Mon, 16 Jul 2012 04:18:07 -0700 (PDT)
Message-ID: <20120716.041807.1735621301109023389.davem@davemloft.net>
References: <1342437352.23494.8.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36804 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752505Ab2GPLSI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 07:18:08 -0400
In-Reply-To: <1342437352.23494.8.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 16 Jul 2012 13:15:52 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Few drivers use GFP_DMA allocations, and netdev_alloc_frag()
> doesn't allocate pages in DMA zone.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
