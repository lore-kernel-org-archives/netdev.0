From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: macb: Remove CONFIG_PM ifdef because of
 compilation warning
Date: Mon, 26 Jan 2015 17:26:30 -0800 (PST)
Message-ID: <20150126.172630.1182911088830479483.davem@davemloft.net>
References: <7970145ad4d864eaf31d694d22f2fecbcf6825c9.1422002161.git.michal.simek@xilinx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, monstr@monstr.eu,
	nicolas.ferre@atmel.com, netdev@vger.kernel.org
To: michal.simek@xilinx.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7970145ad4d864eaf31d694d22f2fecbcf6825c9.1422002161.git.michal.simek@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Simek <michal.simek@xilinx.com>
Date: Fri, 23 Jan 2015 09:36:03 +0100

> Fix compilation warning:
> drivers/net/ethernet/cadence/macb.c:2415:12: warning: 'macb_suspend'
> defined but not used [-Wunused-function]
>  static int macb_suspend(struct device *dev)
> drivers/net/ethernet/cadence/macb.c:2432:12: warning: 'macb_resume'
> defined but not used [-Wunused-function]
>  static int macb_resume(struct device *dev)
> 
> when CONFIG_PM=y, CONFIG_PM_SLEEP=n are used.
> 
> Signed-off-by: Michal Simek <michal.simek@xilinx.com>

Applied.
