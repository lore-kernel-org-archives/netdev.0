From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] mlx4_en XDP TX improvements
Date: Wed, 11 Oct 2017 20:21:41 -0700 (PDT)
Message-ID: <20171011.202141.12082322414332157.davem@davemloft.net>
References: <1507717047-29255-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eranbe@mellanox.com, kernel-team@fb.com
To: tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42140 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752123AbdJLDVm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 23:21:42 -0400
In-Reply-To: <1507717047-29255-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>
Date: Wed, 11 Oct 2017 13:17:24 +0300

> This patchset contains performance improvements
> to the XDP_TX use case in the mlx4 Eth driver.
> 
> Patch 1 is a simple change in a function parameter type.
> Patch 2 replaces a call to a generic function with the
>   relevant parts inlined.
> Patch 3 moves the write of descriptors' constant values
>   from data path to control path.
> 
> Series generated against net-next commit:
> 833e0e2f24fd net: dst: move cpu inside ifdef to avoid compilation warning

Series applied, thanks.
