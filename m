From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2] net/ethernet: remove useless
 is_valid_ether_addr from drivers ndo_open
Date: Mon, 19 Nov 2012 19:03:33 -0500 (EST)
Message-ID: <20121119.190333.1519528868971851100.davem@davemloft.net>
References: <1353077235-342-1-git-send-email-manabian@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, shemminger@vyatta.com,
	steve.glendinning@shawell.net, stigge@antcom.de,
	msink@permonline.ru, netdev@vger.kernel.org
To: manabian@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34753 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752541Ab2KTADf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 19:03:35 -0500
In-Reply-To: <1353077235-342-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joachim Eastwood <manabian@gmail.com>
Date: Fri, 16 Nov 2012 15:47:15 +0100

> If ndo_validate_addr is set to the generic eth_validate_addr
> function there is no point in calling is_valid_ether_addr
> from driver ndo_open if ndo_open is not used elsewhere in
> the driver.
> 
> With this change is_valid_ether_addr will be called from the
> generic eth_validate_addr function. So there should be no change
> in the actual behavior.
> 
> Signed-off-by: Joachim Eastwood <manabian@gmail.com>

Applied, thanks.
