From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb4: mark symbols static where possible
Date: Mon, 19 Sep 2016 21:56:53 -0400 (EDT)
Message-ID: <20160919.215653.605851568652094576.davem@davemloft.net>
References: <1474190303-14976-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hariprasad@chelsio.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, arnd@arndb.de, xie.baoyou@zte.com.cn
To: baoyou.xie@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474190303-14976-1-git-send-email-baoyou.xie@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Baoyou Xie <baoyou.xie@linaro.org>
Date: Sun, 18 Sep 2016 17:18:23 +0800

> We get a few warnings when building kernel with W=1:
> drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c:178:5: warning: no previous prototype for 'setup_sge_queues_uld' [-Wmissing-prototypes]
> drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c:205:6: warning: no previous prototype for 'free_sge_queues_uld' [-Wmissing-prototypes]
> ....
> 
> In fact, these functions are only used in the file in which they are
> declared and don't need a declaration, but can be made static.
> so this patch marks these functions with 'static'.
> 
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>

Does not apply cleanly to net-next, please respin.
