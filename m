From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: ethernet: cpsw: fix build warnings for CPSW
 when CPTS not selected
Date: Wed, 28 Nov 2012 17:51:34 -0500 (EST)
Message-ID: <20121128.175134.357731690357578238.davem@davemloft.net>
References: <1354038820-11095-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-omap@vger.kernel.org, richardcochran@gmail.com
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53694 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755990Ab2K1Wvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 17:51:36 -0500
In-Reply-To: <1354038820-11095-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Tue, 27 Nov 2012 23:23:40 +0530

>   CC      drivers/net/ethernet/ti/cpsw.o
> drivers/net/ethernet/ti/cpsw.c: In function 'cpsw_ndo_ioctl':
> drivers/net/ethernet/ti/cpsw.c:881:20: warning: unused variable 'priv'
> 
> The build warning is generated when CPTS is not selected in Kernel Build.
> Fixing by passing the net_device pointer to cpts IOCTL instead of passing priv
> 
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>

Applied.
