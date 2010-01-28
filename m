From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net/irda: sh_sir: Add SuperH IrDA driver
Date: Wed, 27 Jan 2010 22:08:35 -0800
Message-ID: <20100127220835.287e972d@nehalam>
References: <uiqam6emt.wl%morimoto.kuninori@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Samuel Ortiz <samuel@sortiz.org>,
	"David S. Miller" <davem@davemloft.net>
To: Kuninori Morimoto <morimoto.kuninori@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47217 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752026Ab0A1GIq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jan 2010 01:08:46 -0500
In-Reply-To: <uiqam6emt.wl%morimoto.kuninori@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am happy to see an IRDA driver again, especially one
that doesn't have the UGLY_MACROS that seem to be so
common in that code.

On Thu, 28 Jan 2010 13:24:10 +0900
Kuninori Morimoto <morimoto.kuninori@renesas.com> wrote:

> +struct sh_sir_self {
> +	void __iomem		*membase;
> +	unsigned int		 irq;
> +	struct clk		*clk;
> +
> +	struct net_device	*ndev;
> +
> +	struct net_device_stats	stats;

The network device has stats in netdev->stats now
so devices don't have to keep their own data structure.

Does the device support Fast IR mode?


-- 
