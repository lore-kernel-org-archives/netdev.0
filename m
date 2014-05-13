From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V1 1/9] net/mlx4_core: Enforce irq affinity
 changes immediatly
Date: Tue, 13 May 2014 18:46:19 -0400 (EDT)
Message-ID: <20140513.184619.190705980437081399.davem@davemloft.net>
References: <1399975618-18707-1-git-send-email-amirv@mellanox.com>
	<1399975618-18707-2-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yevgenyp@mellanox.com,
	ogerlitz@mellanox.com, yuvala@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45977 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754646AbaEMWqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 18:46:21 -0400
In-Reply-To: <1399975618-18707-2-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Tue, 13 May 2014 13:06:50 +0300

> +	cq->irq_affinity_change = 0;
 ...
> +			cq->mcq.irq_affinity_change = 0;
 ...
> +		cq->mcq.irq_affinity_change = 0;
 ...
> +		cq->mcq.irq_affinity_change = 0;
 ...
> +		cq->mcq.irq_affinity_change = 0;
 ...
> +			cq->irq_affinity_change = 1;
 ...
> +	bool                    irq_affinity_change;

Since irq_affinity_change is a bool, please assign 'true' and
'false' to it.

Thanks.
