From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 7/8] sfc: Set net_device::num_rx_queues
 once we know the correct value
Date: Tue, 21 Sep 2010 18:38:34 -0700 (PDT)
Message-ID: <20100921.183834.70182767.davem@davemloft.net>
References: <1285009546.2282.126.camel@achroite.uk.solarflarecom.com>
	<20100921.145703.189694076.davem@davemloft.net>
	<1285106878.2697.96.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43886
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755752Ab0IVBiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 21:38:15 -0400
In-Reply-To: <1285106878.2697.96.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 22 Sep 2010 02:31:36 +0100

> Right, but we do need to have some way for drivers to specify the actual
> number of RX queues.

Ok, the problem stems merely from the fact that we only specify one
"queue count" in alloc_netdev_mq().  We should specify two, one for
TX and one for RX.

So why not fix that instead of putting hacks into the drivers? :-)

