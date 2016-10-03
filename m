From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH -next] net: qcom/emac: fix return value check in
 emac_sgmii_config()
Date: Mon, 3 Oct 2016 14:41:11 -0500
Message-ID: <57F2B457.70900@codeaurora.org>
References: <1475313149-15233-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:40424 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752190AbcJCTlO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2016 15:41:14 -0400
In-Reply-To: <1475313149-15233-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wei Yongjun wrote:
> From: Wei Yongjun<weiyongjun1@huawei.com>
>
> In case of error, the function ioremap() returns NULL pointer
> not ERR_PTR(). The IS_ERR() test in the return value check
> should be replaced with NULL test.
>
> Also add check for return value of platform_get_resource().
>
> Fixes: 54e19bc74f33 ("net: qcom/emac: do not use devm on internal
> phy pdev")
> Signed-off-by: Wei Yongjun<weiyongjun1@huawei.com>

Acked-by: Timur Tabi <timur@codeaurora.org>

Thanks for this.  When I switched from devm_ioremap_resource() to 
ioremap(), I didn't think to verify the return values.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
