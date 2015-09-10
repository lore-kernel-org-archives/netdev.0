From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 1/1] net: fec: add netif status check before set
 mac address
Date: Wed, 09 Sep 2015 20:30:36 -0700 (PDT)
Message-ID: <20150909.203036.1906860306892237106.davem@davemloft.net>
References: <1441848939-30108-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	l.stach@pengutronix.de, f.fainelli@gmail.com
To: b38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36950 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752438AbbIJDah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 23:30:37 -0400
In-Reply-To: <1441848939-30108-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <b38611@freescale.com>
Date: Thu, 10 Sep 2015 09:35:39 +0800

> There exist one issue by below case that case system hang:
> ifconfig eth0 down
> ifconfig eth0 hw ether 00:10:19:19:81:19
> 
> After eth0 down, all fec clocks are gated off. In the .fec_set_mac_address()
> function, it will set new MAC address to registers, which causes system hang.
> 
> So it needs to add netif status check to avoid registers access when clocks are
> gated off. Until eth0 up the new MAC address are wrote into related registers.
> 
> V2:
> As Lucas Stach's suggestion, add a comment in the code to explain why it needed.
> 
> CC: Lucas Stach <l.stach@pengutronix.de>
> CC: Florian Fainelli <f.fainelli@gmail.com>
> Signed-off-by: Fugang Duan <B38611@freescale.com>

Applied, thanks.
