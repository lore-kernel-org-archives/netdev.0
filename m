From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] hinic: skb_pad() frees on error
Date: Fri, 25 Aug 2017 17:14:03 -0700 (PDT)
Message-ID: <20170825.171403.275382416735776894.davem@davemloft.net>
References: <20170825082428.hpnbs4i74bubm4cz@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aviad.krawczyk@huawei.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36860 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751881AbdHZAOE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 20:14:04 -0400
In-Reply-To: <20170825082428.hpnbs4i74bubm4cz@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 25 Aug 2017 11:24:28 +0300

> The skb_pad() function frees the skb on error, so this code has a double
> free.
> 
> Fixes: 00e57a6d4ad3 ("net-next/hinic: Add Tx operation")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks.
