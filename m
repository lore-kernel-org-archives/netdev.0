From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] xgene: Don't fail probe, if there is no clk
 resource for SGMII interfaces
Date: Thu, 13 Jul 2017 09:22:15 -0700 (PDT)
Message-ID: <20170713.092215.720040460171963059.davem@davemloft.net>
References: <20170713092144.31751508094@solo.franken.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isubramanian@apm.com, kchudgar@apm.com, qnguyen@apm.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tsbogend@alpha.franken.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170713092144.31751508094@solo.franken.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Date: Thu, 13 Jul 2017 10:57:40 +0200

> From: Thomas Bogendoerfer <tbogendoerfer@suse.de>
> 
> This change fixes following problem
> 
> [    1.827940] xgene-enet: probe of 1f210030.ethernet failed with error -2
> 
> which leads to a missing ethernet interface (reproducable at least on
> Gigabyte MP30-AR0 and APM Mustang systems).
> 
> The check for a valid clk resource fails, because DT doesn't provide a
> clock for sgenet1. But the driver doesn't use this clk, if the ethernet
> port is connected via SGMII. Therefore this patch avoids probing for clk
> on SGMII interfaces.

Applied, thanks.

> Fixes: 9aea7779b764 drivers: net: xgene: Fix crash on DT systems

Please put the commit header text inside of parenthesis and double quotes,
like this:

Fixes: 9aea7779b764 ("drivers: net: xgene: Fix crash on DT systems")

I fixed it up for you this time.
