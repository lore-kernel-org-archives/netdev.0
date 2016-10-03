From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb4: mark cxgb_setup_tc() static
Date: Mon, 03 Oct 2016 01:20:09 -0400 (EDT)
Message-ID: <20161003.012009.1450378180856178912.davem@davemloft.net>
References: <1475220865-18321-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hariprasad@chelsio.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, arnd@arndb.de, xie.baoyou@zte.com.cn,
        han.fei@zte.com.cn, tang.qiang007@zte.com.cn
To: baoyou.xie@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1475220865-18321-1-git-send-email-baoyou.xie@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Baoyou Xie <baoyou.xie@linaro.org>
Date: Fri, 30 Sep 2016 15:34:25 +0800

> We get 1 warning when building kernel with W=1:
> drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c:2715:5: warning: no previous prototype for 'cxgb_setup_tc' [-Wmissing-prototypes]
> 
> In fact, this function is only used in the file in which it is
> declared and don't need a declaration, but can be made static.
> so this patch marks this function with 'static'.
> 
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>

Applied.
