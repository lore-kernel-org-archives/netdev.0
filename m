From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next,V2] Add LAN9352 Ethernet Driver
Date: Tue, 16 Feb 2016 15:52:44 -0500 (EST)
Message-ID: <20160216.155244.2052910262411568012.davem@davemloft.net>
References: <20160216203625.GC2558@lunn.ch>
	<20160216.154358.164326104187806534.davem@davemloft.net>
	<90A7E81AE28BAE4CBDDB3B35F187D264402EFB5D@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org
To: Bryan.Whitehead@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39954 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932233AbcBPUwq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 15:52:46 -0500
In-Reply-To: <90A7E81AE28BAE4CBDDB3B35F187D264402EFB5D@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Bryan.Whitehead@microchip.com>
Date: Tue, 16 Feb 2016 20:48:14 +0000

>> -----Original Message-----
>> From: David Miller [mailto:davem@davemloft.net]
>> Sent: Tuesday, February 16, 2016 3:44 PM
>> To: andrew@lunn.ch
>> Cc: Bryan Whitehead - C21958; f.fainelli@gmail.com; netdev@vger.kernel.org
>> Subject: Re: [PATCH net-next,V2] Add LAN9352 Ethernet Driver
>> 
>> From: Andrew Lunn <andrew@lunn.ch>
>> Date: Tue, 16 Feb 2016 21:36:25 +0100
>> 
>> > So this is the discussion we need to have.
>> >
>> > The interface to the outside work is the two switch ports with real
>> > PHYs. What you are implementing is an Ethernet driver for an internal
>> > port connected to the switch. This port does not go to the outside
>> > world. This driver provides no way to control the ports to the outside
>> > world and you have no short term plan to actually implement control of
>> > the ports connected to the outside world.
>> >
>> > Should the Linux community accept this driver in this state?
>> >
>> > I would prefer to see a simple switchdev or DSA driver which exposes
>> > the two external ports.
>> 
>> I do not think, with all the infrastructure we have, that we should accept pure
>> ethernet drivers for such devices any more.
>> 
>> About year ago I would have responded differently, but these days all of the
>> necessary support and infrastructure is there, and reasonable easy for driver
>> authors to use.
> 
> I believe I can make the physical phys accessible through ethertool. Would that be reasonable?

No, we are asking you to implement DSA or switchdev support.
