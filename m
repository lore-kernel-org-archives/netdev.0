From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 net-next] mlxsw: spectrum: Fix check for IS_ERR()
 instead of NULL
Date: Tue, 03 Oct 2017 10:27:08 -0700 (PDT)
Message-ID: <20171003.102708.974344064764110062.davem@davemloft.net>
References: <20171003105303.u7yrzxknddmmerol@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@mellanox.com, yotamg@mellanox.com, idosch@mellanox.com,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47698 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750767AbdJCR1J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 13:27:09 -0400
In-Reply-To: <20171003105303.u7yrzxknddmmerol@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 3 Oct 2017 13:53:03 +0300

> mlxsw_afa_block_create() doesn't return error pointers, it returns NULL
> on error.
> 
> Fixes: 0e14c7777acb ("mlxsw: spectrum: Add the multicast routing hardware logic")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
