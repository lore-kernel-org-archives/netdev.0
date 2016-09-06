From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vmxnet3: mark vmxnet3_rq_destroy_all_rxdataring()
 static
Date: Tue, 06 Sep 2016 15:59:43 -0700 (PDT)
Message-ID: <20160906.155943.300054680399189957.davem@davemloft.net>
References: <1473149519-25993-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: skhare@vmware.com, pv-drivers@vmware.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, arnd@arndb.de, xie.baoyou@zte.com.cn
To: baoyou.xie@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473149519-25993-1-git-send-email-baoyou.xie@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Baoyou Xie <baoyou.xie@linaro.org>
Date: Tue,  6 Sep 2016 16:11:59 +0800

> We get 1 warning when building kernel with W=1:
> drivers/net/vmxnet3/vmxnet3_drv.c:1643:1: warning: no previous prototype for 'vmxnet3_rq_destroy_all_rxdataring' [-Wmissing-prototypes]
> 
> In fact, this function is only used in the file in which it is
> declared and don't need a declaration, but can be made static.
> so this patch marks this function with 'static'.
> 
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>

This doesn't apply cleanly to net-next.
