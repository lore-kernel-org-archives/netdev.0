From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH -next] sundance: Add initial ethtool stats support
Date: Tue, 12 Oct 2010 13:57:19 -0700
Message-ID: <1286917039.1117.101.camel@Joe-Laptop>
References: <20101009095346.GA12951@hera.kernel.org>
	 <20101009132749.GA15074@solarflare.com>	<4CB0C56C.2000106@kernel.org>
	 <20101012.115138.112614145.davem@davemloft.net>
	 <4CB4C6E6.9090805@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, Ben Hutchings <bhutchings@solarflare.com>,
	Jeff Garzik <jgarzik@redhat.com>
To: Denis Kirjanov <dkirjanov@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2819 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751106Ab0JLVda (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Oct 2010 17:33:30 -0400
In-Reply-To: <4CB4C6E6.9090805@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-10-13 at 00:36 +0400, Denis Kirjanov wrote:

> diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c

Hi Denis.
 
Just a few trivial misspellings of deffered -> deferred

> index 4283cc5..159f7e7 100644
> --- a/drivers/net/sundance.c
> +++ b/drivers/net/sundance.c
> @@ -363,6 +363,19 @@ struct netdev_private {
>          dma_addr_t tx_ring_dma;
>          dma_addr_t rx_ring_dma;
>  	struct timer_list timer;		/* Media monitoring timer. */
> +	/* ethtool extra stats */
> +	struct {
> +		u64 tx_multiple_collisions;
> +		u64 tx_single_collisions;
> +		u64 tx_late_collisions;
> +		u64 tx_deffered;
> +		u64 tx_deffered_excessive;

1

> +	np->xstats.tx_deffered += ioread8(ioaddr + StatsTxDefer);
> +	np->xstats.tx_deffered_excessive += ioread8(ioaddr + StatsTxXSDefer);

2

> +static const struct {
> +	const char name[ETH_GSTRING_LEN];
> +} sundance_stats[] = {
> +	{ "tx_multiple_collisions" },
> +	{ "tx_single_collisions" },
> +	{ "tx_late_collisions" },
> +	{ "tx_deffered" },
> +	{ "tx_deffered_excessive" },

3

> +	data[i++] = np->xstats.tx_deffered;
> +	data[i++] = np->xstats.tx_deffered_excessive;

4

