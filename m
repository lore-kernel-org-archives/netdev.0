From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: [PATCH] net: phy: Add support for SMSC/Microchip LAN9303 3-port switch
Date: Wed, 12 Mar 2014 09:47:20 +0100
Message-ID: <CAGm1_ksBkGi=QqfOyK1cxebNshjQ3UfKqOAUAsWxw98yHErw-g@mail.gmail.com>
References: <1393492072-15364-1-git-send-email-sr@denx.de> <20140227.170240.1910151216729314077.davem@davemloft.net>
 <531057A4.5020607@denx.de> <20140228.130020.2022765291621434648.davem@davemloft.net>
 <CAGm1_ksPrSjV8+o7LCGDtJz_6qY8bqGuqdpYNHKh_6JO2X0sqg@mail.gmail.com> <CAGVrzcZQp0tdig72K0FpPOFQ8edn4T=u6oQNPc8jkKh=1WkM6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, Stefan Roese <sr@denx.de>,
	netdev <netdev@vger.kernel.org>, r.meier@siemens.com,
	lukas.stockmann@siemens.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:60668 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750890AbaCLIrk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 04:47:40 -0400
Received: by mail-pb0-f54.google.com with SMTP id ma3so785594pbc.41
        for <netdev@vger.kernel.org>; Wed, 12 Mar 2014 01:47:40 -0700 (PDT)
In-Reply-To: <CAGVrzcZQp0tdig72K0FpPOFQ8edn4T=u6oQNPc8jkKh=1WkM6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 11, 2014 at 9:14 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> 2014-03-11 13:11 GMT-07:00 Yegor Yefremov <yegorslists@googlemail.com>:
>> On Fri, Feb 28, 2014 at 7:00 PM, David Miller <davem@davemloft.net> wrote:
>>> From: Stefan Roese <sr@denx.de>
>>> Date: Fri, 28 Feb 2014 10:32:20 +0100
>>>
>>>> On 27.02.2014 23:02, David Miller wrote:
>>>>> From: Stefan Roese <sr@denx.de>
>>>>> Date: Thu, 27 Feb 2014 10:07:52 +0100
>>>>>
>>>>> Better is to come up with a real, types, interface for programming
>>>>> such devices and providing an implementation of that.
>>>>
>>>> Right. Such a thing would be better. But as Florian already pointed
>>>> out, nothing like this is available in kernel.org right now. Thats the
>>>> reason why I chose to implement this "simple" driver, btw as done in
>>>> drivers/net/phy/spi_ks8995.c.
>>>
>>> When a suitable user facing interface is lacking, you create one
>>> and submit it for review here.  You don't just submit adhoc driver
>>> local stuff.
>>
>> David, what about enabling ethtool to read/write from/to the PHY
>> registers (via passing PHY ID and register number)? I'm trying to get
>> ICplus IP175D running and it has lots of registers, that I would like
>> to look at dynamically.
>
> ethtool does not do that already for Ethernet MACs attached to a
> single Ethernet PHY, so I do not think this would be the right tool
> for this job. Something custom which uses SIOC{G,S}MIIREG might be
> more suited for this as you would have control over the target PHY
> address.
>
> Maybe swconfig needs to be resubmitted again...

It definitely should. Another option were to create a repo (kernel
fork) at GitHub and create a per release branch for swconfig. This way
people can contribute swconfig compatible drivers for different switch
chips. We would have all source at one central place. And when the
decision about final/official switch interface will be made, we would
have 'only' to rewrite the drivers for the final swconfig version.

Yegor
