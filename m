From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: davinci_emac: fix dev_err use at probe
Date: Thu, 26 May 2011 14:31:00 -0400 (EDT)
Message-ID: <20110526.143100.1615101027208136360.davem@davemloft.net>
References: <1306420652-30001-1-git-send-email-jhovold@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cyril@ti.com, srk@ti.com, netdev@vger.kernel.org
To: jhovold@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54965 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757634Ab1EZSbH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2011 14:31:07 -0400
In-Reply-To: <1306420652-30001-1-git-send-email-jhovold@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johan Hovold <jhovold@gmail.com>
Date: Thu, 26 May 2011 16:37:32 +0200

> Use platform device rather than net device in dev_err calls before net
> device has been registered to avoid messages such as
> 
> 	(null): DaVinci EMAC: Failed to get EMAC clock
> 
> Also replace remaining printks in probe with dev_{err,warn}.
> 
> Signed-off-by: Johan Hovold <jhovold@gmail.com>

Applied, thanks.
