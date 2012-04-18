From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] davinci_mdio: Fix MDIO timeout check
Date: Tue, 17 Apr 2012 22:32:59 -0400 (EDT)
Message-ID: <20120417.223259.2096595530447053760.davem@davemloft.net>
References: <1334586925-11348-1-git-send-email-christian.riesch@omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com,
	ravonereal@gmail.com, manfred.rudigier@omicron.at,
	stable@vger.kernel.org, cyril@ti.com
To: christian.riesch@omicron.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:32849 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752653Ab2DRCdR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 22:33:17 -0400
In-Reply-To: <1334586925-11348-1-git-send-email-christian.riesch@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Riesch <christian.riesch@omicron.at>
Date: Mon, 16 Apr 2012 16:35:25 +0200

> Under heavy load (flood ping) it is possible for the MDIO timeout to
> expire before the loop checks the GO bit again. This patch adds an
> additional check whether the operation was done before actually
> returning -ETIMEDOUT.
> 
> To reproduce this bug, flood ping the device, e.g., ping -f -l 1000
> After some time, a "timed out waiting for user access" warning
> may appear. And even worse, link may go down since the PHY reported a
> timeout.
> 
> Signed-off-by: Christian Riesch <christian.riesch@omicron.at>
> Cc: <stable@vger.kernel.org>
> Cc: Cyril Chemparathy <cyril@ti.com>

Applied.
