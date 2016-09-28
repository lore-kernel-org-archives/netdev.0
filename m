From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] mlx5: Add ndo_poll_controller() implementation
Date: Wed, 28 Sep 2016 04:54:09 -0400 (EDT)
Message-ID: <20160928.045409.1002159444377863778.davem@davemloft.net>
References: <CALzJLG8o3dfPJR-2iaWb-s7r65r51HhgTs5Srf92-Tx0sZCSHw@mail.gmail.com>
        <df7c9e07a041523e13be905d00e74007ecb88c6b.1475014333.git.calvinowens@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm@mellanox.com, matanb@mellanox.com, leonro@mellanox.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel-team@fb.com, saeedm@dev.mellanox.co.il
To: calvinowens@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59206 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751521AbcI1IyM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 04:54:12 -0400
In-Reply-To: <df7c9e07a041523e13be905d00e74007ecb88c6b.1475014333.git.calvinowens@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Calvin Owens <calvinowens@fb.com>
Date: Tue, 27 Sep 2016 15:23:27 -0700

> This implements ndo_poll_controller in net_device_ops callback for mlx5,
> which is necessary to use netconsole with this driver.
> 
> Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>
> Signed-off-by: Calvin Owens <calvinowens@fb.com>
> ---
> Changes in v2:
> 	* Only iterate channels to avoid redundant napi_schedule() calls

This doesn't apply cleanly to net-next, please respin.
