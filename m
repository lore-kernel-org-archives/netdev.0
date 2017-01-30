From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] mlx4: xdp_prog becomes inactive after ethtool '-L'
 or '-G'
Date: Mon, 30 Jan 2017 09:56:52 -0500 (EST)
Message-ID: <20170130.095652.206333902555980419.davem@davemloft.net>
References: <1485589251-3896393-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bblanco@plumgrid.com, saeedm@mellanox.com,
        tariqt@mellanox.com, kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52762 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753655AbdA3Puv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 10:50:51 -0500
In-Reply-To: <1485589251-3896393-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Fri, 27 Jan 2017 23:40:51 -0800

> If the rx-queues ever get re-initialized (e.g. by changing the
> number of rx-queues with ethtool -L), the existing xdp_prog becomes
> inactive.
> 
> The bug is that the xdp_prog ptr has not been carried over from
> the old rx-queues to the new rx-queues
> 
> Fixes: 47a38e155037 ("net/mlx4_en: add support for fast rx drop bpf program")
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>

Mellanox folks, please review.
