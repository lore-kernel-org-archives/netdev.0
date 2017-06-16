From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/10] mlx4 XDP performance improvements
Date: Thu, 15 Jun 2017 22:53:43 -0400 (EDT)
Message-ID: <20170615.225343.2110461670704388500.davem@davemloft.net>
References: <1497526540-30028-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eranbe@mellanox.com, saeedm@mellanox.com,
        kernel-team@fb.com
To: tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42942 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751644AbdFPCxs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 22:53:48 -0400
In-Reply-To: <1497526540-30028-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>
Date: Thu, 15 Jun 2017 14:35:30 +0300

> This patchset contains data-path improvements, mainly for XDP_DROP
> and XDP_TX cases.
> 
> Main patches:
> * Patch 2 by Saeed allows enabling optimized A0 RX steering (in HW) when
>   setting a single RX ring.
>   With this configuration, HW packet-rate dramatically improves,
>   reaching 28.1 Mpps in XDP_DROP case for both IPv4 (37% gain)
>   and IPv6 (53% gain).
> * Patch 6 enhances the XDP xmit function. Among other changes, now we
>   ring one doorbell per NAPI. Patch gives 17% gain in XDP_TX case.
> * Patch 7 obsoletes the NAPI of XDP_TX completion queue and integrates its
>   poll into the respective RX NAPI. Patch gives 15% gain in XDP_TX case.
> 
> Series generated against net-next commit:
> f7aec129a356 rxrpc: Cache the congestion window setting

Series applied, thanks.
