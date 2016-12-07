From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2 6/7] liquidio CN23XX: VF TX buffers
Date: Tue, 06 Dec 2016 21:50:15 -0500 (EST)
Message-ID: <20161206.215015.600446190668658794.davem@davemloft.net>
References: <1481058367-3937-1-git-send-email-rvatsavayi@caviumnetworks.com>
        <1481058367-3937-7-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@caviumnetworks.com,
        derek.chickles@caviumnetworks.com,
        satananda.burla@caviumnetworks.com,
        felix.manlunas@caviumnetworks.com
To: rvatsavayi@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52816 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751266AbcLGC7j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 21:59:39 -0500
In-Reply-To: <1481058367-3937-7-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Date: Tue, 6 Dec 2016 13:06:06 -0800

> diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
> index cf80722..ce5cdcd 100644
> --- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
> +++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
> @@ -270,6 +270,19 @@ static void start_txq(struct net_device *netdev)
>  }
>  
>  /**
> + * \brief Wake a queue
> + * @param netdev network device
> + * @param q which queue to wake
> + */
> +static inline void wake_q(struct net_device *netdev, int q)
 ...
> +static inline int skb_iq(struct lio *lio, struct sk_buff *skb)
 ...
> +static inline int check_txq_state(struct lio *lio, struct sk_buff *skb)

Please do not mark functions inline in foo.c files, let the compiler
decide.
