From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] net/mlx4_core: Enable 4K UAR if SRIOV module
 parameter is not enabled
Date: Fri, 18 Aug 2017 16:16:07 -0700 (PDT)
Message-ID: <20170818.161607.1630814326634748163.davem@davemloft.net>
References: <20170817152952.21592-1-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kamalh@mellanox.com, huyn@mellanox.com
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34726 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751107AbdHRXQI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 19:16:08 -0400
In-Reply-To: <20170817152952.21592-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Thu, 17 Aug 2017 18:29:52 +0300

> From: Huy Nguyen <huyn@mellanox.com>
> 
> enable_4k_uar module parameter was added in patch cited below to
> address the backward compatibility issue in SRIOV when the VM has
> system's PAGE_SIZE uar implementation and the Hypervisor has 4k uar
> implementation.
> 
> The above compatibility issue does not exist in the non SRIOV case.
> In this patch, we always enable 4k uar implementation if SRIOV
> is not enabled on mlx4's supported cards.
> 
> Fixes: 76e39ccf9c36 ("net/mlx4_core: Fix backward compatibility on VFs")
> Signed-off-by: Huy Nguyen <huyn@mellanox.com>
> Reviewed-by: Daniel Jurgens <danielj@mellanox.com>
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>

Applied and queued up for -stable, thanks.
