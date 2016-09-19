From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH] mlx4: fix XDP_TX is acting like XDP_PASS on TX
 ring full
Date: Mon, 19 Sep 2016 01:32:56 -0400 (EDT)
Message-ID: <20160919.013256.1146128345827495736.davem@davemloft.net>
References: <20160916203535.20016.45146.stgit@firesoul>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tariqt@mellanox.com,
        eric.dumazet@gmail.com, tom@herbertland.com, bblanco@plumgrid.com,
        rana.shahot@gmail.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53248 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935439AbcISFdA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 01:33:00 -0400
In-Reply-To: <20160916203535.20016.45146.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Fri, 16 Sep 2016 22:36:12 +0200

> The XDP_TX action can fail transmitting the frame in case the TX ring
> is full or port is down.  In case of TX failure it should drop the
> frame, and not as now call 'break' which is the same as XDP_PASS.
> 
> Fixes: 9ecc2d86171a ("net/mlx4_en: add xdp forwarding and data write support")
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

This patch is for net-next, please be explicit about that in the future.

Applied, thanks.
