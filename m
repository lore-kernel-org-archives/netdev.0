From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers: net: cpsw: make cpsw_ale.c a module
 to allow re-use on Keystone
Date: Sat, 31 Jan 2015 17:36:10 -0800 (PST)
Message-ID: <20150131.173610.754001675443670809.davem@davemloft.net>
References: <1422573351-5603-1-git-send-email-m-karicheri2@ti.com>
	<1422573351-5603-2-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: w-kwok2@ti.com, mugunthanvnm@ti.com, tony@atomide.com,
	prabhakar.csengg@gmail.com, grygorii.strashko@ti.com,
	lokeshvutla@ti.com, mpa@pengutronix.de,
	lsorense@csclub.uwaterloo.ca, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, arnd@arndb.de
To: m-karicheri2@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32847 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754193AbbBABgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2015 20:36:11 -0500
In-Reply-To: <1422573351-5603-2-git-send-email-m-karicheri2@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Murali Karicheri <m-karicheri2@ti.com>
Date: Thu, 29 Jan 2015 18:15:51 -0500

> NetCP on Keystone has cpsw ale function similar to other TI SoCs
> and this driver is re-used. To allow both ti cpsw and keystone netcp
> to re-use the driver, convert the cpsw ale to a module and configure
> it through Kconfig option CONFIG_TI_CPSW_ALE. Currently it is statically
> linked to both TI CPSW and NetCP and this causes issues when the above
> drivers are built as dynamic modules. This patch addresses this issue
> 
> While at it, fix the Makefile and code to build both netcp_core and
> netcp_ethss as dynamic modules. This is needed to support arm allmodconfig.
> This also requires exporting of API calls provided by netcp_core so that
> both the above can be dynamic modules.
> 
> Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>

Applied, thanks
