From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net/mlx5e: Support bpf_xdp_adjust_head()
Date: Wed, 18 Jan 2017 11:31:27 -0500 (EST)
Message-ID: <20170118.113127.2274827131322198278.davem@davemloft.net>
References: <1484719567-2774431-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, saeedm@mellanox.com, tariqt@mellanox.com,
        kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35974 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751505AbdARQkx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 11:40:53 -0500
In-Reply-To: <1484719567-2774431-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Tue, 17 Jan 2017 22:06:07 -0800

> This patch adds bpf_xdp_adjust_head() support to mlx5e.
> 
> 1. rx_headroom is added to struct mlx5e_rq.  It uses
>    an existing 4 byte hole in the struct.
> 2. The adjusted data length is checked against
>    MLX5E_XDP_MIN_INLINE and MLX5E_SW2HW_MTU(rq->netdev->mtu).
> 3. The macro MLX5E_SW2HW_MTU is moved from en_main.c to en.h.
>    MLX5E_HW2SW_MTU is also moved to en.h for symmetric reason
>    but it is not a must.
> 
> v2:
> - Keep the xdp specific logic in mlx5e_xdp_handle()
> - Update dma_len after the sanity checks in mlx5e_xmit_xdp_frame()
> 
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>

Applied.
