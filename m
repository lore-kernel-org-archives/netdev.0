From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: Avoid race in sky2_change_mtu
Date: Mon, 03 May 2010 15:37:12 -0700 (PDT)
Message-ID: <20100503.153712.93376700.davem@davemloft.net>
References: <4BDEDB50.7000707@ring3k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: mikem@ring3k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45976
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753447Ab0ECWhG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 18:37:06 -0400
In-Reply-To: <4BDEDB50.7000707@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike McCormack <mikem@ring3k.org>
Date: Mon, 03 May 2010 23:18:56 +0900

> netif_stop_queue does not ensure all in-progress transmits are complete,
>  so use netif_tx_disable() instead.
> 
> Make sure NAPI polls are disabled, otherwise NAPI might trigger a TX
>  restart between when we stop the queue and NAPI is disabled.
> 
> Signed-off-by: Mike McCormack <mikem@ring3k.org>

This looks quite reasonable, Stephen please review.
