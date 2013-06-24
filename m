From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH 1/1] drivers: net: cpsw: fix compilation error with
 cpsw driver
Date: Mon, 24 Jun 2013 00:28:56 -0700 (PDT)
Message-ID: <20130624.002856.1010271760097885230.davem@davemloft.net>
References: <1371822309-13704-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37734 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753040Ab3FXH25 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 03:28:57 -0400
In-Reply-To: <1371822309-13704-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Fri, 21 Jun 2013 19:15:09 +0530

> drivers/net/ethernet/ti/cpsw.c: In function 'cpsw_suspend':
> drivers/net/ethernet/ti/cpsw.c:1979:26: error: 'priv' undeclared (first use in this function)
> drivers/net/ethernet/ti/cpsw.c:1979:26: note: each undeclared identifier is reported only once for each function it appears in
> make[4]: *** [drivers/net/ethernet/ti/cpsw.o] Error 1
> 
> The compilation error was introduced by the following commit
> 6d3d76f (drivers: net: cpsw: fix cpsw clock gating issue across suspend/resume)
> 
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>

Applied.
