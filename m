From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Subject: [PATCH 2/6] bna: Brocade 10Gb Ethernet device driver
Date: Mon, 23 Nov 2009 20:26:20 -0800
Message-ID: <20091123202620.5ead8af2@s6510>
References: <200911240351.nAO3p1AY025627@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <adapter_linux_open_src_team@brocade.com>
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57209 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757952AbZKXE0l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2009 23:26:41 -0500
In-Reply-To: <200911240351.nAO3p1AY025627@blc-10-10.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Nov 2009 19:51:01 -0800
Rasesh Mody <rmody@brocade.com> wrote:

> +/**
> + *  bna_rxf_frame_stats_get()
> + *
> + *  For RxF "rxf_id", it loads frame statistics into "stats_ptr".
> + *
> + * @param[in]  dev     - pointer to BNA device structure
> + * @param[in]  rxf_id  - rx-function ID.
> + * @param[out]  stats_ptr - pointer to stats structure to fill
> + *
> + * @return BNA_OK   - successful
> + * @return BNA_FAIL - failed on sanity checks.
> + */
> +void bna_rxf_frame_stats_get(struct bna_dev *dev, unsigned int rxf_id,
> +	struct bna_stats_rxf **stats_ptr)
> +{
> +
> +	BNA_ASSERT(rxf_id < BNA_RXF_ID_MAX);
> +
> +	*stats_ptr = &dev->stats.rxf_stats[rxf_id];
> +}

20 lines to do the work of 1!
