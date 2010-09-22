From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next-2.6 7/8] sfc: Set net_device::num_rx_queues
 once we know the correct value
Date: Wed, 22 Sep 2010 16:28:47 +0100
Message-ID: <1285169327.2279.3.camel@achroite.uk.solarflarecom.com>
References: <1285009546.2282.126.camel@achroite.uk.solarflarecom.com>
	 <20100921.145703.189694076.davem@davemloft.net>
	 <1285106878.2697.96.camel@localhost>
	 <20100921.183834.70182767.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:55977 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753741Ab0IVP2u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 11:28:50 -0400
In-Reply-To: <20100921.183834.70182767.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-09-21 at 18:38 -0700, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Wed, 22 Sep 2010 02:31:36 +0100
> 
> > Right, but we do need to have some way for drivers to specify the actual
> > number of RX queues.
> 
> Ok, the problem stems merely from the fact that we only specify one
> "queue count" in alloc_netdev_mq().  We should specify two, one for
> TX and one for RX.
> 
> So why not fix that instead of putting hacks into the drivers? :-)

That still doesn't solve the original problem, since drivers generally
won't know how many RX queues they should (or can) create until some
time after calling alloc_netdev_mq().

You know very well why we distinguish real_num_tx_queues and
num_tx_queues; what's so different about RX queues?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

