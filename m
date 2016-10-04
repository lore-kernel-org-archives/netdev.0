From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: qcom/emac: fix return value check in
 emac_sgmii_config()
Date: Mon, 03 Oct 2016 21:53:38 -0400 (EDT)
Message-ID: <20161003.215338.665781390718403445.davem@davemloft.net>
References: <1475313149-15233-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timur@codeaurora.org, weiyongjun1@huawei.com,
        netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52792 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751259AbcJDBxl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2016 21:53:41 -0400
In-Reply-To: <1475313149-15233-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Sat,  1 Oct 2016 09:12:29 +0000

> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> In case of error, the function ioremap() returns NULL pointer
> not ERR_PTR(). The IS_ERR() test in the return value check
> should be replaced with NULL test.
> 
> Also add check for return value of platform_get_resource().
> 
> Fixes: 54e19bc74f33 ("net: qcom/emac: do not use devm on internal
> phy pdev")
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Applied, thanks.
