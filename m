From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: ti: cpsw: wake tx queues on
 ndo_tx_timeout
Date: Sun, 02 Apr 2017 19:43:06 -0700 (PDT)
Message-ID: <20170402.194306.1830349337879774492.davem@davemloft.net>
References: <20170331234123.15607-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsekhar@ti.com,
        linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org,
        ivan.khoronzhuk@linaro.org
To: grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170331234123.15607-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grygorii Strashko <grygorii.strashko@ti.com>
Date: Fri, 31 Mar 2017 18:41:23 -0500

> In case, if TX watchdog is fired some or all netdev TX queues will be
> stopped and as part of recovery it is required not only to drain and
> reinitailize CPSW TX channeles, but also wake up stoppted TX queues what
> doesn't happen now and netdevice will stop transmiting data until
> reopenned.
> 
> Hence, add netif_tx_wake_all_queues() call in .ndo_tx_timeout() to complete
> recovery and restore TX path.
> 
> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>

Applied, thank you.
