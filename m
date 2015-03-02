From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ti: cpsw: add hibernation callbacks
Date: Sun, 01 Mar 2015 23:27:20 -0500 (EST)
Message-ID: <20150301.232720.675390758407649123.davem@davemloft.net>
References: <1425035985-8875-1-git-send-email-grygorii.strashko@linaro.org>
	<1425035985-8875-2-git-send-email-grygorii.strashko@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: balbi@ti.com, nm@ti.com, sumit.semwal@linaro.org,
	mugunthanvnm@ti.com, netdev@vger.kernel.org,
	linux-omap@vger.kernel.org
To: grygorii.strashko@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46439 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753148AbbCBE1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 23:27:21 -0500
In-Reply-To: <1425035985-8875-2-git-send-email-grygorii.strashko@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <grygorii.strashko@linaro.org>
Date: Fri, 27 Feb 2015 13:19:45 +0200

> From: Grygorii Strashko <Grygorii.Strashko@linaro.org>
> 
> Setting a dev_pm_ops suspend/resume pair but not a set of
> hibernation functions means those pm functions will not be
> called upon hibernation.
> Fix this by using SIMPLE_DEV_PM_OPS, which appropriately
> assigns the suspend and hibernation handlers and move
> cpsw_suspend/resume calbacks under CONFIG_PM_SLEEP
> to avoid build warnings.
> 
> Signed-off-by: Grygorii Strashko <Grygorii.Strashko@linaro.org>

Applied.
