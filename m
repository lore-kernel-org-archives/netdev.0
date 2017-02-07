From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: ti: cpsw: remove netif_trans_update
Date: Tue, 07 Feb 2017 13:37:11 -0500 (EST)
Message-ID: <20170207.133711.898814361878285175.davem@davemloft.net>
References: <1486421625-24413-1-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, grygorii.strashko@ti.com,
        netdev@vger.kernel.org, linux-omap@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: ivan.khoronzhuk@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486421625-24413-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Date: Tue,  7 Feb 2017 00:53:45 +0200

> No need to update jiffies in txq->trans_start twice, it's supposed to be
> done in netdev_start_xmit() and anyway is re-written. Also, no reason to
> update trans time in case of an error.
> 
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
> ---
> Based on net-next/master

Applied, thank you.
