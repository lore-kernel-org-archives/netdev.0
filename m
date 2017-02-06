From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2] mlx4: Invoke softirqs after napi_reschedule
Date: Mon, 06 Feb 2017 10:47:07 -0800
Message-ID: <1486406827.7793.45.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1486403641.7793.43.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170206181431.9664-1-bpoirier@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        Yishai Hadas <yishaih@mellanox.com>, linux-rdma@vger.kernel.org
To: Benjamin Poirier <bpoirier@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35591 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751437AbdBFSrJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 13:47:09 -0500
In-Reply-To: <20170206181431.9664-1-bpoirier@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-02-06 at 10:14 -0800, Benjamin Poirier wrote:
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
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)


Acked-by: Eric Dumazet <edumazet@google.com>

Thanks
