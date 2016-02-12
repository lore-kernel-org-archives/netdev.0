From: <Bryan.Whitehead@microchip.com>
Subject: RE: [PATCH net-next,V2] Add LAN9352 Ethernet Driver
Date: Fri, 12 Feb 2016 16:53:03 +0000
Message-ID: <90A7E81AE28BAE4CBDDB3B35F187D264402EF5BB@CHN-SV-EXMX02.mchp-main.com>
References: <90A7E81AE28BAE4CBDDB3B35F187D264402EF4A2@CHN-SV-EXMX02.mchp-main.com>
 <56BD40F1.2030707@gmail.com> <20160212072040.GC8046@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <andrew@lunn.ch>, <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp03.microchip.com ([198.175.253.49]:46370 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751467AbcBLQxE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2016 11:53:04 -0500
In-Reply-To: <20160212072040.GC8046@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian,
I'm not familiar with the DSA subsystem. Can you refer me to documents about it?

Andrew,
I'm also not familiar with switchdev, or which is better in this case. Can you refer me to documents about it?

At this point my plan is to just get a basic Ethernet controller driver submitted, and later work on switch features.

Regards,
Bryan


-----Original Message-----
From: Andrew Lunn [mailto:andrew@lunn.ch] 
Sent: Friday, February 12, 2016 2:21 AM
To: Florian Fainelli
Cc: Bryan Whitehead - C21958; davem@davemloft.net; netdev@vger.kernel.org
Subject: Re: [PATCH net-next,V2] Add LAN9352 Ethernet Driver

On Thu, Feb 11, 2016 at 06:18:25PM -0800, Florian Fainelli wrote:
> On 11/02/16 10:58, Bryan.Whitehead@microchip.com wrote:
> > This is the initial submission of an ethernet driver for the 
> > Microchip LAN9352.
> > 
> > The LAN9352 is a 2-Port 10/100 Managed Ethernet Switch with 16-Bit 
> > Non-PCI CPU Interface. The CPU interface includes a basic ethernet 
> > controller interface whose virtual phy is connected internally to a 
> > 3rd port on the embedded switch.
> > 
> > This driver only operates as a simple ethernet controller on the CPU 
> > interface. Since this interface is connected directly to the 
> > embedded switch, the result is that traffic can be sent and received 
> > on both physical ports.
> 
> If this is an integrated switch, have you considered using the DSA 
> subsystem and having this driver just be the Ethernet driver that 
> interfaces to your CPU interface, but does not attempt to configure 
> the switch in any way?

I actually think switchdev might be the better model. Hard to say. The datasheet suggests it could be modelled as a three port switch, so DSA might be appropriate...

      Andrew
