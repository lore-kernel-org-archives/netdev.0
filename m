From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] NET: Multiple queue hardware support
Date: Thu, 21 Jun 2007 23:31:52 +0200
Message-ID: <467AEE48.5050902@trash.net>
References: <20070621212629.31066.92148.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	auke-jan.h.kok@intel.com, hadi@cyberus.ca
To: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47686 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755686AbXFUVcQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2007 17:32:16 -0400
In-Reply-To: <20070621212629.31066.92148.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PJ Waskiewicz wrote:
> I did not modify other users of netif_queue_stopped() in net/core/netpoll.c,
> net/core/dev.c, or net/core/pktgen.c, since no classification occurs for
> the skb being sent to the device.  Therefore, packets should always be
> ending up in queue 0, so there's no need to check the subqueue status either.
>   

Thats not correct. Subqueue 0 may be full and the queue still running.

I'll look over the patches later.

