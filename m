From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: [PATCH] net: phy: Add support for SMSC/Microchip LAN9303 3-port switch
Date: Tue, 11 Mar 2014 21:11:16 +0100
Message-ID: <CAGm1_ksPrSjV8+o7LCGDtJz_6qY8bqGuqdpYNHKh_6JO2X0sqg@mail.gmail.com>
References: <1393492072-15364-1-git-send-email-sr@denx.de> <20140227.170240.1910151216729314077.davem@davemloft.net>
 <531057A4.5020607@denx.de> <20140228.130020.2022765291621434648.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stefan Roese <sr@denx.de>, netdev <netdev@vger.kernel.org>,
	r.meier@siemens.com, lukas.stockmann@siemens.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:43577 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755419AbaCKULh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 16:11:37 -0400
Received: by mail-pa0-f50.google.com with SMTP id kq14so38477pab.23
        for <netdev@vger.kernel.org>; Tue, 11 Mar 2014 13:11:37 -0700 (PDT)
In-Reply-To: <20140228.130020.2022765291621434648.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 28, 2014 at 7:00 PM, David Miller <davem@davemloft.net> wrote:
> From: Stefan Roese <sr@denx.de>
> Date: Fri, 28 Feb 2014 10:32:20 +0100
>
>> On 27.02.2014 23:02, David Miller wrote:
>>> From: Stefan Roese <sr@denx.de>
>>> Date: Thu, 27 Feb 2014 10:07:52 +0100
>>>
>>> Better is to come up with a real, types, interface for programming
>>> such devices and providing an implementation of that.
>>
>> Right. Such a thing would be better. But as Florian already pointed
>> out, nothing like this is available in kernel.org right now. Thats the
>> reason why I chose to implement this "simple" driver, btw as done in
>> drivers/net/phy/spi_ks8995.c.
>
> When a suitable user facing interface is lacking, you create one
> and submit it for review here.  You don't just submit adhoc driver
> local stuff.

David, what about enabling ethtool to read/write from/to the PHY
registers (via passing PHY ID and register number)? I'm trying to get
ICplus IP175D running and it has lots of registers, that I would like
to look at dynamically.

Yegor
