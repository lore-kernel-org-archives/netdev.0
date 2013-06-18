From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] net/mlx4_en: Low Latency recv statistics
Date: Mon, 17 Jun 2013 17:01:41 -0700 (PDT)
Message-ID: <20130617.170141.1635117503399974407.davem@davemloft.net>
References: <1371466703-3370-1-git-send-email-amirv@mellanox.com>
	<1371466703-3370-3-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eliezer.tamir@linux.intel.com,
	ogerlitz@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40704 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130Ab3FRABo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 20:01:44 -0400
In-Reply-To: <1371466703-3370-3-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Mon, 17 Jun 2013 13:58:23 +0300

> +#ifdef CONFIG_NET_LL_RX_POLL
> +#define LL_EXTENDED_STATS
> +#endif

Don't convert standard Kconfig CPP defines into your own internal thing.

I'm not applying this series until you fix this.
