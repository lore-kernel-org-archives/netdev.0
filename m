From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] net/mlx5: Avoid dereferencing uninitialized
 pointer
Date: Tue, 28 Mar 2017 18:07:48 -0700 (PDT)
Message-ID: <20170328.180748.1911072556720820281.davem@davemloft.net>
References: <20170328131341.11601-1-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, talatb@mellanox.com
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40008 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932571AbdC2BHu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 21:07:50 -0400
In-Reply-To: <20170328131341.11601-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Tue, 28 Mar 2017 16:13:41 +0300

> From: Talat Batheesh <talatb@mellanox.com>
> 
> In NETDEV_CHANGEUPPER event the upper_info field is valid
> only when linking is true. Otherwise it should be ignored.
> 
> Fixes: 7907f23adc18 (net/mlx5: Implement RoCE LAG feature)
> Signed-off-by: Talat Batheesh <talatb@mellanox.com>
> Reviewed-by: Aviv Heller <avivh@mellanox.com>
> Reviewed-by: Moni Shoua <monis@mellanox.com>
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
> ---
> 
> Hi Dave,
> 
> I will appreciate it if you queue up this patch for v4.9-stable.

Applied and queued up for -stable, thanks.
