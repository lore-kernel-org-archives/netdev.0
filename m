From: Matt Wilson <msw@amzn.com>
Subject: Re: [PATCH net-next] net: ena: Add a driver for Amazon Elastic
 Network Adapters (ENA)
Date: Wed, 15 Jun 2016 11:07:17 -0700
Message-ID: <20160615180717.GA14049@u54ee753d2d1854bda401.ant.amazon.com>
References: <1465807573-11293-1-git-send-email-netanel@annapurnalabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemeloft.net,
	linux-kernel@vger.kernel.org, zorik@annapurnalabs.com,
	saeed@annapurnalabs.com, alex@annapurnalabs.com,
	aliguori@amazon.com, antoine.tenart@free-electrons.com
To: Netanel Belgazal <netanel@annapurnalabs.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1465807573-11293-1-git-send-email-netanel@annapurnalabs.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 13, 2016 at 11:46:13AM +0300, Netanel Belgazal wrote:
> This is a driver for the forthcoming ENA family of networking devices.
> 
> Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>

[...]

> +
> +struct ena_napi {
> +	struct napi_struct napi ____cacheline_aligned;
> +	struct ena_ring *tx_ring;
> +	struct ena_ring *rx_ring;
> +#ifndef HAVE_NETDEV_NAPI_LIST
> +	struct net_device poll_dev;
> +#endif /* HAVE_NETDEV_NAPI_LIST */
> +	u32 qid;
> +};

Netanel,

Sorry I missed this when I read through the patch earlier this week
(though I pointed it out before...). This "#ifndef
HAVE_NETDEV_NAPI_LIST" bit needs to be removed for the in-tree
version.

You also had a few typos in the email addresses on the Cc: line that
I've corrected (davm@avemeloft.net -> davem@davemeloft.net,
aligouri@amazon.com -> aliguori@amazon.com). Please make sure to
correct in your v2 patch.

--msw
