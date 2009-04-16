From: David Miller <davem@davemloft.net>
Subject: Re: sparc: struct device - replace bus_id with dev_name(),
 dev_set_name()
Date: Thu, 16 Apr 2009 15:56:43 -0700 (PDT)
Message-ID: <20090416.155643.06066521.davem@davemloft.net>
References: <ac3eb2510903270521i113df787u7ac5d842ece83740@mail.gmail.com>
	<20090327.172743.30040617.davem@davemloft.net>
	<1239898912.17211.7.camel@poy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greg@kroah.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: kay.sievers@vrfy.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38867
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753472AbZDPW4v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 18:56:51 -0400
In-Reply-To: <1239898912.17211.7.camel@poy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kay Sievers <kay.sievers@vrfy.org>
Date: Thu, 16 Apr 2009 18:21:52 +0200

> On Fri, 2009-03-27 at 17:27 -0700, David Miller wrote:
>> From: Kay Sievers <kay.sievers@vrfy.org>
>> Date: Fri, 27 Mar 2009 13:21:56 +0100
>> 
>> > it took a while, but it happened now, so this issue is coming back. :)
>> > 
>> > The name size limit is gone, there is no BUS_ID_SIZE thing anymore in
>> > the driver core. BUS_ID_SIZE should go away in the 2.6.30 timeframe.
>> > 
>> > Could you please convert/remove BUS_ID_SIZE value from:
>> >   drivers/net/gianfar.h:	char	phy_bus_id[BUS_ID_SIZE];
>> >   drivers/net/ucc_geth.h:	char phy_bus_id[BUS_ID_SIZE];
>> >   drivers/net/pasemi_mac.h:	char	phy_id[BUS_ID_SIZE];
>> >   include/linux/phy.h:#define MII_BUS_ID_SIZE	(BUS_ID_SIZE - 3)
>> >   include/linux/phy.h:	char bus_id[BUS_ID_SIZE];
>> > 
>> > Or let me know how you want to convert it, so I can do it?
>> 
>> Thanks a lot Kay, I'll look into these cases and take care
>> of it.
> 
> This moves the 20 into the netdevice header, we need to get rid
> of the driver core define now, otherwise people start adding new
> code using it, and we want to finish this thankless job finally. :)

I was working on fixing this properly Kay, please be patient.

I'll have it killed off in net-next-2.6 soon enough.
