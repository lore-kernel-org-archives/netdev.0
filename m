From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V3 0/3] mlx4 XDP TX refactor
Date: Wed, 02 Nov 2016 15:07:32 -0400 (EDT)
Message-ID: <20161102.150732.381279885899371736.davem@davemloft.net>
References: <1478099545-24181-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eranbe@mellanox.com, bblanco@plumgrid.com,
        alexei.starovoitov@gmail.com, saeedm@mellanox.com
To: tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45136 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752815AbcKBTHe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 15:07:34 -0400
In-Reply-To: <1478099545-24181-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>
Date: Wed,  2 Nov 2016 17:12:22 +0200

> This patchset refactors the XDP forwarding case, so that
> its dedicated transmit queues are managed in a complete
> separation from the other regular ones.
> 
> It also adds ethtool counters for XDP cases.
> 
> Series generated against net-next commit:
> 22ca904ad70a genetlink: fix error return code in genl_register_family()
 ...
> v3:
> * Exposed per ring counters.
> 
> v2:
> * Added ethtool counters.
> * Rebased, now patch 2 reverts Brenden's fix, as the bug no longer exists:
>   958b3d396d7f ("net/mlx4_en: fixup xdp tx irq to match rx")
> * Updated commit message of patch 2.

Series applied, thanks.
