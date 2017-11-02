From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: hns3: remove a couple of redundant assignments
Date: Thu, 02 Nov 2017 15:54:11 +0900 (KST)
Message-ID: <20171102.155411.1611979100337438252.davem@davemloft.net>
References: <20171101101715.17617-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yisen.zhuang@huawei.com, salil.mehta@huawei.com,
        linyunsheng@huawei.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171101101715.17617-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Wed,  1 Nov 2017 10:17:15 +0000

> From: Colin Ian King <colin.king@canonical.com>
> 
> The assignment to kinfo is redundant as this is a duplicate of
> the initialiation of kinfo a few lines earlier, so it can be
> removed.  The assignment to v_tc_info is never read, so this
> variable is redundant and can be removed completely. Cleans
> up two clang warnings:
> 
> drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c:433:34:
> warning: Value stored to 'kinfo' during its initialization is never read
> drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c:775:3:
> warning: Value stored to 'v_tc_info' is never read
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
