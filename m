From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: netcp: correct netcp_get_stats function
 signature
Date: Wed, 11 Jan 2017 10:48:45 -0500 (EST)
Message-ID: <20170111.104845.293231110827245659.davem@davemloft.net>
References: <1484105609-8647-1-git-send-email-j-keerthy@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: w-kwok2@ti.com, m-karicheri2@ti.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, stephen@networkplumber.org,
        m-scherban@ti.com
To: j-keerthy@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51564 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967711AbdAKPss (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 10:48:48 -0500
In-Reply-To: <1484105609-8647-1-git-send-email-j-keerthy@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Keerthy <j-keerthy@ti.com>
Date: Wed, 11 Jan 2017 09:03:29 +0530

> Commit: bc1f44709cf2 - net: make ndo_get_stats64 a void function
> and
> Commit: 6a8162e99ef3 - net: netcp: store network statistics in 64 bits.
> 
> The commit 6a8162e99ef3 adds ndo_get_stats64 function as per old
> signature which causes compilation error:
> 
> drivers/net/ethernet/ti/netcp_core.c:1951:28: error:
> initialization from incompatible pointer type
>   .ndo_get_stats64        = netcp_get_stats,
> 
> Hence correct netcp_get_stats function signature as per
> the latest definition.
> 
> Signed-off-by: Keerthy <j-keerthy@ti.com>
> Fixes: 6a8162e99ef344fc("net: netcp: store network statistics in 64 bits")

Applied, thanks.
