From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] drivers: net:cpsw: fix probe_dt when only slave 1
 is pinned out
Date: Tue, 28 Oct 2014 15:44:53 -0400 (EDT)
Message-ID: <20141028.154453.598640416374877321.davem@davemloft.net>
References: <1414156893-1884-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34734 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750727AbaJ1TpA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 15:45:00 -0400
In-Reply-To: <1414156893-1884-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Fri, 24 Oct 2014 18:51:33 +0530

> when slave 0 has no phy and slave 1 connected to phy, driver probe will
> fail as there is no phy id present for slave 0 device tree, so continuing
> even though no phy-id found, also moving mac-id read later to ensure
> mac-id is read from device tree even when phy-id entry in not found.
> 
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>

Applied, thanks.
