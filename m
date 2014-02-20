From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: fix potential issue to avoid fec interrupt
 lost and crc error
Date: Thu, 20 Feb 2014 13:16:33 -0500 (EST)
Message-ID: <20140220.131633.960783426585782185.davem@davemloft.net>
References: <1392891279-11194-1-git-send-email-B38611@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: b20596@freescale.com, netdev@vger.kernel.org
To: B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57585 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754705AbaBTSQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Feb 2014 13:16:35 -0500
In-Reply-To: <1392891279-11194-1-git-send-email-B38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <B38611@freescale.com>
Date: Thu, 20 Feb 2014 18:14:39 +0800

> The current flow: Set TX BD ready, and then set "INT" and "PINS" bit to
> enable tx interrupt generation and crc checksum.
> 
> There has potential issue like as:
> CPU			fec uDMA
> Set tx ready bit
> 			uDMA start the BD transmission
> Set "INT" bit
> Set "PINS" bit
> ...
> 
> Above situation cause fec tx interrupt lost and fec MAC don't do
> CRC checksum. The patch fix the potential issue.
> 
> Signed-off-by: Fugang Duan <B38611@freescale.com>

Applied, thank you.
