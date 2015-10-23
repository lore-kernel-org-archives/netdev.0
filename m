From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: net: cpsw: use module_platform_driver
Date: Fri, 23 Oct 2015 05:48:35 -0700 (PDT)
Message-ID: <20151023.054835.575367388673659421.davem@davemloft.net>
References: <1445600472-19242-1-git-send-email-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsekhar@ti.com, mugunthanvnm@ti.com,
	linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	tony@atomide.com
To: grygorii.strashko@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34612 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751616AbbJWMcH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 08:32:07 -0400
In-Reply-To: <1445600472-19242-1-git-send-email-grygorii.strashko@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grygorii Strashko <grygorii.strashko@ti.com>
Date: Fri, 23 Oct 2015 14:41:12 +0300

> There is no reasons to probe cpsw from late_initcall level
> and it's not recommended. Hence, use module_platform_driver()
> to register and probe cpsw driver from module_init() level.
> 
> Cc: Tony Lindgren <tony@atomide.com>
> Acked-by: Mugunthan V N <mugunthanvnm@ti.com>
> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>

Applied to net-next, thanks.
