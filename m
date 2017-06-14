From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/mlxfw: fix a NULL dereference
Date: Wed, 14 Jun 2017 15:33:08 -0400 (EDT)
Message-ID: <20170614.153308.341504181230845534.davem@davemloft.net>
References: <20170614104152.GM29394@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yotamg@mellanox.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54442 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751760AbdFNTdK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 15:33:10 -0400
In-Reply-To: <20170614104152.GM29394@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 14 Jun 2017 13:41:52 +0300

> If we hit this error path we end up returning ERR_PTR(0) which is NULL.
> The caller is not expecting that so it results in a NULL dereference.
> 
> Fixes: 410ed13cae39 ("Add the mlxfw module for Mellanox firmware flash process")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
