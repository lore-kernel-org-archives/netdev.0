From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next 8/8] net/mlx5e: XDP TX xmit more
Date: Tue, 20 Sep 2016 09:46:29 +0200
Message-ID: <20160920094629.12e78a85@redhat.com>
References: <1474293539-2595-1-git-send-email-tariqt@mellanox.com>
        <1474293539-2595-9-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, "David S. Miller" <davem@davemloft.net>,
        netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Rana Shahout <ranas@mellanox.com>
To: Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58756 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751282AbcITHqe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Sep 2016 03:46:34 -0400
In-Reply-To: <1474293539-2595-9-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 19 Sep 2016 16:58:59 +0300
Tariq Toukan <tariqt@mellanox.com> wrote:

> From: Saeed Mahameed <saeedm@mellanox.com>
> 
> Previously we rang XDP SQ doorbell on every forwarded XDP packet.
> 
> Here we introduce a xmit more like mechanism that will queue up more
> than one packet into SQ (up to RX napi budget) w/o notifying the hardware.
>
> Once RX napi budget is consumed and we exit napi RX loop, we will
> flush (doorbell) all XDP looped packets in case there are such.

I've already raised strong concerns with this approach on the RFC
patchset.  Of not really taking advantage of RX bulking.
Please do not ignore this!

If you can promise, that we/you will also try to other approach I'm
suggesting, then I'm fine with this patch.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
