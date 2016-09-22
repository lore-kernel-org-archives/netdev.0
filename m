From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ptp_clock: future-proofing drivers against PTP
 subsystem becoming optional
Date: Thu, 22 Sep 2016 02:18:56 -0400 (EDT)
Message-ID: <20160922.021856.219321683253472628.davem@davemloft.net>
References: <alpine.LFD.2.20.1609201915070.9311@knanqh.ubzr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, john.stultz@linaro.org,
        tglx@linutronix.de, josh@joshtriplett.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: nicolas.pitre@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.20.1609201915070.9311@knanqh.ubzr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicolas Pitre <nicolas.pitre@linaro.org>
Date: Tue, 20 Sep 2016 19:25:58 -0400 (EDT)

> 
> Drivers must be ready to accept NULL from ptp_clock_register() if the
> PTP clock subsystem is configured out.
> 
> This patch documents that and ensures that all drivers cope well
> with a NULL return.
> 
> Signed-off-by: Nicolas Pitre <nico@linaro.org>
> Reviewed-by: Eugenia Emantayev <eugenia@mellanox.com>
> 
> ---
> 
> Let's have the basics merged now and work out the actual Kconfig issue 
> separately. Richard, if you agree with this patch, I think this could go 
> via the netdev tree.

Applied to net-next, thanks.
