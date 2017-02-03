From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 0/2] mlx4: Misc bug fixes after reinitializing
 queues
Date: Thu, 02 Feb 2017 21:27:33 -0500 (EST)
Message-ID: <20170202.212733.1191806964720115305.davem@davemloft.net>
References: <1485930933-4159518-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, saeedm@mellanox.com, tariqt@mellanox.com,
        kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37104 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751622AbdBCC1r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 21:27:47 -0500
In-Reply-To: <1485930933-4159518-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Tue, 31 Jan 2017 22:35:31 -0800

> This patchset fixes misc bugs after reinitializing
> queues (e.g. by ethtool -L).
> 
> v2:
> * Add another fix to mem leak in tx_ring[t] and tx_cq[t]
> * In mlx4_en_try_alloc_resources(),
>   move all xdp_prog logic after calling mlx4_en_alloc_resources()

Series applied, thanks.
