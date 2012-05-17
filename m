From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4] be2net: Fix to allow get/set of debug
 levels in the firmware.
Date: Thu, 17 May 2012 16:21:16 -0400 (EDT)
Message-ID: <20120517.162116.881586126577077171.davem@davemloft.net>
References: <23cb36ad-2827-44bd-a91a-c6d8b01db70e@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	suresh.reddy@emulex.com
To: somnath.kotur@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34739 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757930Ab2EQUV3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 16:21:29 -0400
In-Reply-To: <23cb36ad-2827-44bd-a91a-c6d8b01db70e@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@emulex.com>
Date: Mon, 14 May 2012 21:59:28 +0530

> Fixed missing paranthesis warning
> Incorporated review comments by Ben Hutchings.
> 
> Signed-off-by: Suresh Reddy <suresh.reddy@emulex.com>
> Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>

This doesn't apply cleanly to net-next, please respin.

Also, you should convert your driver now to use ->msg_enable to gate
all of your driver's kernel message logging, not just this firmware
stuff.
