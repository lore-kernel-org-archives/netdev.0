From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/8] at91_ether share stats/address setting with macb
Date: Wed, 07 Nov 2012 17:45:59 -0500 (EST)
Message-ID: <20121107.174559.1342851979726401731.davem@davemloft.net>
References: <1352312097-31320-1-git-send-email-manabian@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, plagnioj@jcrosoft.com,
	netdev@vger.kernel.org
To: manabian@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41885 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751404Ab2KGWqA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 17:46:00 -0500
In-Reply-To: <1352312097-31320-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joachim Eastwood <manabian@gmail.com>
Date: Wed,  7 Nov 2012 19:14:49 +0100

> Patch 1-2 add support for some special at91_ether features to macb address setting code. This will allow us to have one address setting function that can be shared.
> 
> Patch 4 removes the at91_ether address set/get code and make use of the exported functions for macb.
> 
> Patch 5 remove the at91_ether statistics functions and replace them with equivalent function from macb.
> 
> Patch 6 removes an unused member from the at91_ether/macb private struct.
> 
> Patch 7 is a clean up of the print outs from at91_ether.
> 
> Patch 8 is a misc clean up patch which fixes some comment and style issues.
> 
> 
> Most of the code left in at91_ether now deal with configuration and DMA rx/tx which is hard to share with macb since this is specific for the IP block in AT91RM9200.
> 
> Next I'll work on adding PHY GPIO interrupt to the macb driver. at91_ether had this functionality before it began using mdio functions from macb.

All applied to net-next, thanks.
