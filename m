From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/5] sky2: Allocate initial skbs in sky2_alloc_buffers
Date: Wed, 10 Feb 2010 08:04:52 -0800
Message-ID: <20100210080452.75ee8ab2@nehalam>
References: <4B72BEB1.10908@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60905 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755184Ab0BJQFJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2010 11:05:09 -0500
In-Reply-To: <4B72BEB1.10908@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 10 Feb 2010 23:12:01 +0900
Mike McCormack <mikem@ring3k.org> wrote:

> +		re->skb = sky2_rx_alloc(sky2);
> +		if (!re->skb)
> +			goto nomem;
> +
> +		if (sky2_rx_map_skb(hw->pdev, re, sky2->rx_data_size)) {
> +			dev_kfree_skb(re->skb);
> +			re->skb = NULL;
> +			goto nomem;
> +		}
> +	}
> +	return 0;
> +nomem:
> +	return -ENOMEM;

I like this and will put it all together with my patch set
But will get rid of silly things goto a return statement.

-- 
