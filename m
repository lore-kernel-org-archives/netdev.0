From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: cpsw: Fix ethernet regression for dm814x
Date: Fri, 20 Nov 2015 10:47:11 -0500 (EST)
Message-ID: <20151120.104711.524014130095052102.davem@davemloft.net>
References: <1447896445-6120-1-git-send-email-tony@atomide.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-omap@vger.kernel.org,
	mugunthanvnm@ti.com
To: tony@atomide.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60924 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751338AbbKTPrN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2015 10:47:13 -0500
In-Reply-To: <1447896445-6120-1-git-send-email-tony@atomide.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Lindgren <tony@atomide.com>
Date: Wed, 18 Nov 2015 17:27:25 -0800

> Commit b6745f6e4e63 ("drivers: net: cpsw: davinci_emac: move reading mac
> id to common file") started using of_machine_is_compatible for detecting
> type but missed at dm8148 causing Ethernet to stop working.
> 
> Let's fix the issue by adding handling for dm814x.
> 
> Cc: Mugunthan V N <mugunthanvnm@ti.com>
> Signed-off-by: Tony Lindgren <tony@atomide.com>

Applied, thank you.
