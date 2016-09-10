From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qede: mark qede_set_features() static
Date: Fri, 09 Sep 2016 18:16:57 -0700 (PDT)
Message-ID: <20160909.181657.1693562341995049282.davem@davemloft.net>
References: <1473324203-9065-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@qlogic.com, Ariel.Elior@qlogic.com,
        everest-linux-l2@qlogic.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, arnd@arndb.de, xie.baoyou@zte.com.cn
To: baoyou.xie@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473324203-9065-1-git-send-email-baoyou.xie@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Baoyou Xie <baoyou.xie@linaro.org>
Date: Thu,  8 Sep 2016 16:43:23 +0800

> We get 1 warning when building kernel with W=1:
> drivers/net/ethernet/qlogic/qede/qede_main.c:2113:5: warning: no previous prototype for 'qede_set_features' [-Wmissing-prototypes]
> 
> In fact, this function is only used in the file in which it is
> declared and don't need a declaration, but can be made static.
> so this patch marks this function with 'static'.
> 
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>

Applied.
