From: Tom Herbert <therbert@google.com>
Subject: [PATCH 0/3] net: RX and TX queue allocation cleanup
Date: Mon, 18 Oct 2010 11:02:06 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.1010181053200.15812@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: eric.dumazet@gmail.com, bhutchings@solarflare.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:20984 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933006Ab0JRSCS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 14:02:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move TX queue allocation to register_netdevice.  Enforce
alloc_netdev_mq & netif_set_real_num_[rt]x_queues netif_alloc_rx_queues
are called with at least one queue to allocate.
