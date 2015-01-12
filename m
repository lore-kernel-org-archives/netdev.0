From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/at91_ether: prepare and unprepare clock
Date: Mon, 12 Jan 2015 15:35:59 -0500 (EST)
Message-ID: <20150112.153559.783855617585288378.davem@davemloft.net>
References: <1420671566-30784-1-git-send-email-alexandre.belloni@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, boris.brezillon@free-electrons.com,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: alexandre.belloni@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420671566-30784-1-git-send-email-alexandre.belloni@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Date: Wed,  7 Jan 2015 23:59:26 +0100

> The clock is enabled without being prepared, this leads to:
> 
> WARNING: CPU: 0 PID: 1 at drivers/clk/clk.c:889 __clk_enable+0x24/0xa8()
> 
> and a non working ethernet interface.
> 
> Use clk_prepare_enable() and clk_disable_unprepare() to handle the clock.
> 
> Signed-off-by: Alexandre Belloni <alexandre.belloni@free-electrons.com>

Applied, thanks.
