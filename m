From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] net/mlx4_en: fix a condition
Date: Mon, 06 Feb 2017 12:01:14 -0500 (EST)
Message-ID: <20170206.120114.1158013558292422641.davem@davemloft.net>
References: <20170203095459.GA5704@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yishaih@mellanox.com, shakerd@mellanox.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43168 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751728AbdBFRBQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 12:01:16 -0500
In-Reply-To: <20170203095459.GA5704@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 3 Feb 2017 12:54:59 +0300

> There is a "||" vs "|" typo here so we test 0x1 instead of 0x6.
> 
> Fixes: 1f8176f7352a ("net/mlx4_en: Check the enabling pptx/pprx flags in SET_PORT wrapper flow")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
