From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH V3] mlx4: fix XDP_TX is acting like XDP_PASS on TX
 ring full
Date: Mon, 19 Sep 2016 01:39:25 -0400 (EDT)
Message-ID: <20160919.013925.1660395475687226712.davem@davemloft.net>
References: <20160917164650.53e68314@redhat.com>
        <20160917154753.3130.16986.stgit@firesoul>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tariqt@mellanox.com, tom@herbertland.com,
        bblanco@plumgrid.com, rana.shahot@gmail.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53314 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934266AbcISFje (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 01:39:34 -0400
In-Reply-To: <20160917154753.3130.16986.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Sat, 17 Sep 2016 17:48:00 +0200

> The XDP_TX action can fail transmitting the frame in case the TX ring
> is full or port is down.  In case of TX failure it should drop the
> frame, and not as now call 'break' which is the same as XDP_PASS.
> 
> Fixes: 9ecc2d86171a ("net/mlx4_en: add xdp forwarding and data write support")
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Oops, I applied v2 of this patch.  Please send me any necessary
relative fixups, thanks.
