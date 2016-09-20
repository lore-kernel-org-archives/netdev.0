From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH V2] mlx4: add missed recycle opportunity for
 XDP_TX on TX failure
Date: Tue, 20 Sep 2016 04:58:43 -0400 (EDT)
Message-ID: <20160920.045843.1654100968407894492.davem@davemloft.net>
References: <1474295315.22679.85.camel@edumazet-glaptop3.roam.corp.google.com>
        <20160919154556.10965.75722.stgit@firesoul>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tariqt@mellanox.com,
        eric.dumazet@gmail.com, tom@herbertland.com, bblanco@plumgrid.com,
        rana.shahot@gmail.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45426 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932282AbcITI6q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 04:58:46 -0400
In-Reply-To: <20160919154556.10965.75722.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Mon, 19 Sep 2016 17:46:38 +0200

> Correct drop handling for XDP_TX on TX failure, were recently added in
> commit 95357907ae73 ("mlx4: fix XDP_TX is acting like XDP_PASS on TX
> ring full").
> 
> The change missed an opportunity for recycling the RX page, instead of
> going through the page allocator, like the regular XDP_DROP action does.
> This patch cease the opportunity, by going through the XDP_DROP case.
> 
> Fixes: 95357907ae73 ("mlx4: fix XDP_TX is acting like XDP_PASS on TX ring full")
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> Reviewed-by: Tariq Toukan <tariqt@mellanox.com>

Applied, thanks.
