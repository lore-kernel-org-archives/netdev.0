From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: hip04: mark tx_done() static
Date: Mon, 26 Sep 2016 02:24:37 -0400 (EDT)
Message-ID: <20160926.022437.239315766739111882.davem@davemloft.net>
References: <1474795144-15983-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yisen.zhuang@huawei.com, salil.mehta@huawei.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, xie.baoyou@zte.com.cn, han.fei@zte.com.cn,
        tang.qiang007@zte.com.cn
To: baoyou.xie@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474795144-15983-1-git-send-email-baoyou.xie@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Baoyou Xie <baoyou.xie@linaro.org>
Date: Sun, 25 Sep 2016 17:19:04 +0800

> We get 1 warning when building kernel with W=1:
> drivers/net/ethernet/hisilicon/hip04_eth.c:603:22: warning: no previous prototype for 'tx_done' [-Wmissing-prototypes]
> 
> In fact, this function is only used in the file in which it is
> declared and don't need a declaration, but can be made static.
> so this patch marks this function with 'static'.
> 
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>

Applied.
