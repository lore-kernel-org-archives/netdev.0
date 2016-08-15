From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: hns: mdio->irq is an array, so no need to check
 if it is null
Date: Mon, 15 Aug 2016 13:39:03 -0700 (PDT)
Message-ID: <20160815.133903.1454433408106419676.davem@davemloft.net>
References: <1471265717-10784-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yisen.zhuang@huawei.com, salil.mehta@huawei.com,
	yankejian@huawei.com, huangdaode@hisilicon.com,
	lipeng321@huawei.com, lisheng011@huawei.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471265717-10784-1-git-send-email-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Mon, 15 Aug 2016 13:55:17 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> The null check on mdio->irq is redundant since mdio->irq is an array
> of PHY_MAX_ADDR ints and hence can never be null. Remove the redundant
> check.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied, thanks.
