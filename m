From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] can: fix NOHZ local_softirq_pending 08 warning
Date: Tue, 15 Sep 2009 01:31:40 -0700 (PDT)
Message-ID: <20090915.013140.97444184.davem@davemloft.net>
References: <4AAF3AF2.60309@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stable@kernel.org, netdev@vger.kernel.org, urs@isnogud.escape.de,
	mb@bu3sch.de
To: oliver@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33585
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750738AbZIOIbX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2009 04:31:23 -0400
In-Reply-To: <4AAF3AF2.60309@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <oliver@hartkopp.net>
Date: Tue, 15 Sep 2009 08:57:54 +0200

> When using nanosleep() in an userspace application we get a ratelimit warning
> 
> NOHZ: local_softirq_pending 08
> 
> for 10 times.
> 
> The echo of CAN frames is done from process context and softirq context only.
> Therefore the usage of netif_rx() was wrong (for years).
> 
> This patch replaces netif_rx() with netif_rx_ni() which has to be used from
> process/softirq context. It also adds a missing comment that can_send() must
> no be used from hardirq context.
> 
> Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>
> Signed-off-by: Urs Thuermann <urs@isnogud.escape.de>

Applied, thanks.
