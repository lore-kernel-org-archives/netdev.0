From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-next] net: hns3: ensure media_type is unitialized
Date: Thu, 17 Aug 2017 10:06:35 -0700 (PDT)
Message-ID: <20170817.100635.571751073337398396.davem@davemloft.net>
References: <20170817090107.14310-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yisen.zhuang@huawei.com, salil.mehta@huawei.com,
        huangdaode@hisilicon.com, lipeng321@huawei.com,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170817090107.14310-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Thu, 17 Aug 2017 10:01:07 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> Media type is only set if h->ae_algo->ops->get_media_type is called
> so there is a possibility that media_type is uninitialized when it is
> used a switch statement.  Fix this by initializing media_type to
> HNAE3_MEDIA_TYPE_UNKNOWN.
> 
> Detected by CoverityScan, CID#1452624("Uninitialized scalar variable")
> 
> Fixes: 496d03e960ae ("net: hns3: Add Ethtool support to HNS3 driver")
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
