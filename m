From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH 1/1] drivers: net: cpsw: fix cpsw clock gating
 issue across suspend/resume
Date: Wed, 19 Jun 2013 18:34:16 -0700 (PDT)
Message-ID: <20130619.183416.530352072063563371.davem@davemloft.net>
References: <1371548076-22035-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47194 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935237Ab3FTBeR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 21:34:17 -0400
In-Reply-To: <1371548076-22035-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Tue, 18 Jun 2013 15:04:35 +0530

> Due to some hardware integration issue, CPSW sliver modules requires a
> reset across suspend/resume cycle for a successful clock gating to
> CPGMAC (CPSW and Davinci MDIO) in AM335x PG1.0.
> This issue is fixed in PG2.x, though to support suspend/resume on PG1.0
> this reset is required.
> 
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>

Applied, thanks.
