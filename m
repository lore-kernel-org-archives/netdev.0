From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2 0/8] mlx5e XDP support
Date: Thu, 22 Sep 2016 02:55:37 -0400 (EDT)
Message-ID: <20160922.025537.1612668257047147207.davem@davemloft.net>
References: <1474449589-27035-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eranbe@mellanox.com, ranas@mellanox.com,
        saeedm@mellanox.com
To: tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55596 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754184AbcIVGzk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 02:55:40 -0400
In-Reply-To: <1474449589-27035-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>
Date: Wed, 21 Sep 2016 12:19:41 +0300

> This series adds XDP support in mlx5e driver.
> This includes the use cases: XDP_DROP, XDP_PASS, and XDP_TX.
> 
> Single stream performance tests show 16.5 Mpps for XDP_DROP,
> and 12.4 Mpps for XDP_TX, with nice scalability for multiple streams/rings.
> 
> This rate of XDP_DROP is lower than the 32 Mpps we got in previous
> implementation, when Striding RQ was used.
> 
> We moved to non-Striding RQ, as some XDP_TX requirements (like headroom,
> packet-per-page) cannot be satisfied with the current Striding RQ HW,
> and we decided to fully support both DROP/TX.
> 
> Few directions are considered in order to enable the faster rate for XDP_DROP,
> e.g a possibility for users to enable Striding RQ so they choose optimized
> XDP_DROP on the price of partial XDP_TX functionality, or some HW changes.
> 
> Series generated against net-next commit:
> cf714ac147e0 'ipvlan: Fix dependency issue'

Series applied, thanks.
