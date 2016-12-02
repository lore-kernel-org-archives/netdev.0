From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2 0/7] Mellanox 100G mlx5 updates 2016-11-29
Date: Fri, 02 Dec 2016 10:47:21 -0500 (EST)
Message-ID: <20161202.104721.2191746743620868559.davem@davemloft.net>
References: <1480521583-12755-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tariqt@mellanox.com, ogerlitz@mellanox.com,
        roid@mellanox.com, sebott@linux.vnet.ibm.com
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35552 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752526AbcLBPrY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 10:47:24 -0500
In-Reply-To: <1480521583-12755-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Wed, 30 Nov 2016 17:59:36 +0200

> The following series from Tariq and Roi, provides some critical fixes
> and updates for the mlx5e driver.
> 
> From Tariq: 
>  - Fix driver coherent memory huge allocation issues by fragmenting
>    completion queues, in a way that is transparent to the netdev driver by
>    providing a new buffer type "mlx5_frag_buf" with the same access API.
>  - Create UMR MKey per RQ to have better scalability.
> 
> From Roi:
>  - Some fixes for the encap-decap support and tc flower added lately to the
>    mlx5e driver.
> 
> v1->v2:
>  - Fix start index in error flow of mlx5_frag_buf_alloc_node, pointed out by Eric.
> 
> This series was generated against commit:
> 31ac1c19455f ("geneve: fix ip_hdr_len reserved for geneve6 tunnel.")

Series applied, thanks.
