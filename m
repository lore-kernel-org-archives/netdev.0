From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] mlx4: Invoke softirqs after napi_reschedule
Date: Tue, 07 Feb 2017 12:51:54 -0500 (EST)
Message-ID: <20170207.125154.1590393488220239361.davem@davemloft.net>
References: <1486403641.7793.43.camel@edumazet-glaptop3.roam.corp.google.com>
        <20170206181431.9664-1-bpoirier@suse.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tariqt@mellanox.com, yishaih@mellanox.com,
        linux-rdma@vger.kernel.org, eric.dumazet@gmail.com
To: bpoirier@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52808 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932194AbdBGRv4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 12:51:56 -0500
In-Reply-To: <20170206181431.9664-1-bpoirier@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Poirier <bpoirier@suse.com>
Date: Mon,  6 Feb 2017 10:14:31 -0800

> mlx4 may schedule napi from a workqueue. Afterwards, softirqs are not run
> in a deterministic time frame and the following message may be logged:
> NOHZ: local_softirq_pending 08
> 
> The problem is the same as what was described in commit ec13ee80145c
> ("virtio_net: invoke softirqs after __napi_schedule") and this patch
> applies the same fix to mlx4.
> 
> Fixes: 07841f9d94c1 ("net/mlx4_en: Schedule napi when RX buffers allocation fails")
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Benjamin Poirier <bpoirier@suse.com>

Applied and queued up for -stable, thanks!
