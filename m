From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phy/micrel: Fix ID of KSZ9021
Date: Tue, 22 May 2012 15:21:21 -0400 (EDT)
Message-ID: <20120522.152121.83882047024872698.davem@davemloft.net>
References: <1337646008-24568-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, david.choi@micrel.com
To: nobuhiro.iwamatsu.yj@renesas.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50085 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750929Ab2EVTVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2012 15:21:31 -0400
In-Reply-To: <1337646008-24568-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Date: Tue, 22 May 2012 09:20:08 +0900

> Right ID of KSZ9021 is 0x00221610.
> Because lower 4bit is a revision number, it varies according to a chip.
> 
> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>

Applied, but this shouldn't matter and it should not have any
effect on functionality.

All of the code knows how to properly mask out the revision because
of MICRL_PHY_ID_MASK and the the .phy_id_mask specified in the
ksz9021_driver entry.
