From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: davinci_mdio: add hibernation callbacks
Date: Sun, 01 Mar 2015 23:27:14 -0500 (EST)
Message-ID: <20150301.232714.1468134019624934794.davem@davemloft.net>
References: <1425035985-8875-1-git-send-email-grygorii.strashko@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: balbi@ti.com, nm@ti.com, sumit.semwal@linaro.org,
	mugunthanvnm@ti.com, netdev@vger.kernel.org,
	linux-omap@vger.kernel.org
To: grygorii.strashko@linaro.org
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1425035985-8875-1-git-send-email-grygorii.strashko@linaro.org>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: <grygorii.strashko@linaro.org>
Date: Fri, 27 Feb 2015 13:19:44 +0200

> From: Grygorii Strashko <Grygorii.Strashko@linaro.org>
> 
> Setting a dev_pm_ops suspend_late/resume_early pair but not a
> set of hibernation functions means those pm functions will
> not be called upon hibernation.
> Fix this by using SET_LATE_SYSTEM_SLEEP_PM_OPS, which appropriately
> assigns the suspend and hibernation handlers and move
> davinci_mdio_x callbacks under CONFIG_PM_SLEEP to avoid build warnings.
> 
> Signed-off-by: Grygorii Strashko <Grygorii.Strashko@linaro.org>

Applied.
