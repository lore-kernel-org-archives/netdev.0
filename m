From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] broadcom: fix PHY_ID_BCM5481 entry in the id table
Date: Mon, 23 Nov 2015 23:30:15 -0500 (EST)
Message-ID: <20151123.233015.2174569039797624312.davem@davemloft.net>
References: <1448147334-10518-1-git-send-email-aaro.koskinen@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: aaro.koskinen@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60850 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751836AbbKXEaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 23:30:20 -0500
In-Reply-To: <1448147334-10518-1-git-send-email-aaro.koskinen@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaro Koskinen <aaro.koskinen@iki.fi>
Date: Sun, 22 Nov 2015 01:08:54 +0200

> Commit fcb26ec5b18d ("broadcom: move all PHY_ID's to header")
> updated broadcom_tbl to use PHY_IDs, but incorrectly replaced 0x0143bca0
> with PHY_ID_BCM5482 (making a duplicate entry, and completely omitting
> the original). Fix that.
> 
> Fixes: fcb26ec5b18d ("broadcom: move all PHY_ID's to header")
> Signed-off-by: Aaro Koskinen <aaro.koskinen@iki.fi>

Applied and queued up for -stable, thanks.
