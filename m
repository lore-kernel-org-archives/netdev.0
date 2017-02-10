From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: ti: netcp_core: remove
 netif_trans_update
Date: Fri, 10 Feb 2017 13:53:02 -0500 (EST)
Message-ID: <20170210.135302.1970516180801550856.davem@davemloft.net>
References: <1486649860-8824-1-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: w-kwok2@ti.com, m-karicheri2@ti.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: ivan.khoronzhuk@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486649860-8824-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Date: Thu,  9 Feb 2017 16:17:40 +0200

> No need to update jiffies in txq->trans_start twice and only for tx 0,
> it's supposed to be done in netdev_start_xmit() and per tx queue.
> 
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
> ---
> Based on net-next/master

Applied, thanks.
