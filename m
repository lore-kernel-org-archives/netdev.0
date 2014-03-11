From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: Add support for SMSC/Microchip LAN9303
 3-port switch
Date: Tue, 11 Mar 2014 16:39:24 -0400 (EDT)
Message-ID: <20140311.163924.934541574802061078.davem@davemloft.net>
References: <531057A4.5020607@denx.de>
	<20140228.130020.2022765291621434648.davem@davemloft.net>
	<CAGm1_ksPrSjV8+o7LCGDtJz_6qY8bqGuqdpYNHKh_6JO2X0sqg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sr@denx.de, netdev@vger.kernel.org, r.meier@siemens.com,
	lukas.stockmann@siemens.com, f.fainelli@gmail.com
To: yegorslists@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58398 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755845AbaCKUj0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 16:39:26 -0400
In-Reply-To: <CAGm1_ksPrSjV8+o7LCGDtJz_6qY8bqGuqdpYNHKh_6JO2X0sqg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yegor Yefremov <yegorslists@googlemail.com>
Date: Tue, 11 Mar 2014 21:11:16 +0100

> On Fri, Feb 28, 2014 at 7:00 PM, David Miller <davem@davemloft.net> wrote:
>> From: Stefan Roese <sr@denx.de>
>> Date: Fri, 28 Feb 2014 10:32:20 +0100
>>
>>> On 27.02.2014 23:02, David Miller wrote:
>>>> From: Stefan Roese <sr@denx.de>
>>>> Date: Thu, 27 Feb 2014 10:07:52 +0100
>>>>
>>>> Better is to come up with a real, types, interface for programming
>>>> such devices and providing an implementation of that.
>>>
>>> Right. Such a thing would be better. But as Florian already pointed
>>> out, nothing like this is available in kernel.org right now. Thats the
>>> reason why I chose to implement this "simple" driver, btw as done in
>>> drivers/net/phy/spi_ks8995.c.
>>
>> When a suitable user facing interface is lacking, you create one
>> and submit it for review here.  You don't just submit adhoc driver
>> local stuff.
> 
> David, what about enabling ethtool to read/write from/to the PHY
> registers (via passing PHY ID and register number)? I'm trying to get
> ICplus IP175D running and it has lots of registers, that I would like
> to look at dynamically.

For debugging, register dumps are already supported by ethtool.
