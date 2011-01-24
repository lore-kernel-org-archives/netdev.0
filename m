From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 3/5] net: RPS: Enable hardware
 acceleration of RFS
Date: Mon, 24 Jan 2011 15:01:49 -0800 (PST)
Message-ID: <20110124.150149.59666436.davem@davemloft.net>
References: <1295470787.11126.82.camel@bwh-desktop>
	<1295471033.11126.87.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	therbert@google.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42227
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752922Ab1AXXBP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jan 2011 18:01:15 -0500
In-Reply-To: <1295471033.11126.87.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 19 Jan 2011 21:03:53 +0000

> Allow drivers for multiqueue hardware with flow filter tables to
> accelerate RFS.  The driver must:
> 
> 1. Set net_device::rx_cpu_rmap to a cpu_rmap of the RX completion
> IRQs (in queue order).  This will provide a mapping from CPUs to the
> queues for which completions are handled nearest to them.
> 
> 2. Implement net_device_ops::ndo_rx_flow_steer.  This operation adds
> or replaces a filter steering the given flow to the given RX queue, if
> possible.
> 
> 3. Periodically remove filters for which rps_may_expire_flow() returns
> true.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
