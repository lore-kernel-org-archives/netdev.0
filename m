From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] net: RX and TX queue allocation cleanup
Date: Wed, 20 Oct 2010 02:30:41 -0700 (PDT)
Message-ID: <20101020.023041.112586469.davem@davemloft.net>
References: <alpine.DEB.1.00.1010181053200.15812@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	bhutchings@solarflare.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36140
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751865Ab0JTJaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Oct 2010 05:30:19 -0400
In-Reply-To: <alpine.DEB.1.00.1010181053200.15812@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 18 Oct 2010 11:02:06 -0700 (PDT)

> Move TX queue allocation to register_netdevice.  Enforce
> alloc_netdev_mq & netif_set_real_num_[rt]x_queues netif_alloc_rx_queues
> are called with at least one queue to allocate.

All applied, and I fixed the indentation issue Eric noticed
while integrating.

Thanks.
