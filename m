From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: dsa: bcm_sf2: fix 64-bits register reads
Date: Fri, 20 Feb 2015 17:52:58 -0500 (EST)
Message-ID: <20150220.175258.108097845897582111.davem@davemloft.net>
References: <1424372967-27938-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47753 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752745AbbBTWxA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 17:53:00 -0500
In-Reply-To: <1424372967-27938-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 19 Feb 2015 11:09:27 -0800

> Reading 64-bits register was not working because we inverted the steps
> between reading the lower 32-bits of the register and reading the upper
> 32-bits. Swapping these operations is how the HW guarantees that 64-bits
> reads are latched correctly. We only have a handful of 64-bits registers
> for now, mostly MIB counters, so the imapct is low.
> 
> Fixes: 246d7f773c13 ("net: dsa: add Broadcom SF2 switch driver")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks Florian.
