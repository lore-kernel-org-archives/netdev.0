From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: ti: cpsw: use var instead of func for
 usage count
Date: Tue, 14 Feb 2017 22:30:56 -0500 (EST)
Message-ID: <20170214.223056.1842864503781156614.davem@davemloft.net>
References: <1487080956-28661-1-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, grygorii.strashko@ti.com,
        netdev@vger.kernel.org, linux-omap@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: ivan.khoronzhuk@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1487080956-28661-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Date: Tue, 14 Feb 2017 16:02:36 +0200

> The usage count function is based on ndev_running flag that is
> updated before calling ndo_open/close, but if ndo is called in
> another place, as with suspend/resume, the counter is not changed,
> that breaks sus/resume. For common resource no difference which
> device is using it, does matter only device count. So, replace
> usage count function on var and inc and dec it in ndo_open/close.
> 
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
> ---
> Based on net-next/master

Applied, thanks.
