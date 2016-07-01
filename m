From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mvneta: fix open() error cleanup
Date: Fri, 01 Jul 2016 06:00:41 -0400 (EDT)
Message-ID: <20160701.060041.1316708391279704866.davem@davemloft.net>
References: <20160630093615.GK1041@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, thomas.petazzoni@free-electrons.com,
	jon@solid-run.com
To: linux@armlinux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37567 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752470AbcGAKBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 06:01:32 -0400
In-Reply-To: <20160630093615.GK1041@n2100.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King - ARM Linux <linux@armlinux.org.uk>
Date: Thu, 30 Jun 2016 10:36:15 +0100

> If mvneta_mdio_probe() fails, a kernel warning is triggered due to
> missing cleanup in the error path.  Add the necessary cleanup.
 ...
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>

Applied.
