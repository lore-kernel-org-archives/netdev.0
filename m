From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: Add support for SMSC/Microchip LAN9303
 3-port switch
Date: Fri, 28 Feb 2014 13:00:20 -0500 (EST)
Message-ID: <20140228.130020.2022765291621434648.davem@davemloft.net>
References: <1393492072-15364-1-git-send-email-sr@denx.de>
	<20140227.170240.1910151216729314077.davem@davemloft.net>
	<531057A4.5020607@denx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, r.meier@siemens.com,
	lukas.stockmann@siemens.com, f.fainelli@gmail.com
To: sr@denx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57619 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752914AbaB1SAW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 13:00:22 -0500
In-Reply-To: <531057A4.5020607@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Roese <sr@denx.de>
Date: Fri, 28 Feb 2014 10:32:20 +0100

> On 27.02.2014 23:02, David Miller wrote:
>> From: Stefan Roese <sr@denx.de>
>> Date: Thu, 27 Feb 2014 10:07:52 +0100
>>
>> Better is to come up with a real, types, interface for programming
>> such devices and providing an implementation of that.
> 
> Right. Such a thing would be better. But as Florian already pointed
> out, nothing like this is available in kernel.org right now. Thats the
> reason why I chose to implement this "simple" driver, btw as done in
> drivers/net/phy/spi_ks8995.c.

When a suitable user facing interface is lacking, you create one
and submit it for review here.  You don't just submit adhoc driver
local stuff.
