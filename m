From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] mlx5e Order-0 pages for Striding RQ
Date: Sat, 17 Sep 2016 09:52:09 -0400 (EDT)
Message-ID: <20160917.095209.1895526809537006544.davem@davemloft.net>
References: <1473944918-31290-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eranbe@mellanox.com, saeedm@mellanox.com
To: tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60008 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751304AbcIQNwM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2016 09:52:12 -0400
In-Reply-To: <1473944918-31290-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>
Date: Thu, 15 Sep 2016 16:08:35 +0300

> In this series, we refactor our Striding RQ receive-flow to always use
> fragmented WQEs (Work Queue Elements) using order-0 pages, omitting the
> flow that allocates and splits high-order pages which would fragment
> and deplete high-order pages in the system.
> 
> The first patch gives a slight degradation, but opens the opportunity
> to using a simple page-cache mechanism of a fair size.
> The page-cache, implemented in patch 3, not only closes the performance
> gap but even gives a gain.
> In patch 2 we re-organize the code to better manage the calls for
> alloc/de-alloc pages in the RX flow.
> 
> Series generated against net-next commit:
> bed806cb266e "Merge branch 'mlxsw-ethtool'"

Series applied, thanks.
