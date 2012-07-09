From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bcm87xx: disable autonegotiation by default
Date: Mon, 09 Jul 2012 00:09:54 -0700 (PDT)
Message-ID: <20120709.000954.1322446066520940381.davem@davemloft.net>
References: <1341398037-7591-1-git-send-email-jacmet@sunsite.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, david.daney@cavium.com
To: jacmet@sunsite.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53549 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751631Ab2GIHJy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 03:09:54 -0400
In-Reply-To: <1341398037-7591-1-git-send-email-jacmet@sunsite.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Korsgaard <jacmet@sunsite.dk>
Date: Wed,  4 Jul 2012 12:33:57 +0200

> The bcm87xx phys don't support autonegotiation, so don't use it by
> default, as otherwise phy_state_machine() will try to enable it (using
> c22 requests, which also don't make any sense for the bcm78xx).
> 
> Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>

Applied to net-next, thanks.
