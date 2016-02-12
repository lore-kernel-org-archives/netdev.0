From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next,V2] Add LAN9352 Ethernet Driver
Date: Fri, 12 Feb 2016 08:20:40 +0100
Message-ID: <20160212072040.GC8046@lunn.ch>
References: <90A7E81AE28BAE4CBDDB3B35F187D264402EF4A2@CHN-SV-EXMX02.mchp-main.com>
 <56BD40F1.2030707@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bryan.Whitehead@microchip.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44854 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750827AbcBLHUq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Feb 2016 02:20:46 -0500
Content-Disposition: inline
In-Reply-To: <56BD40F1.2030707@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 11, 2016 at 06:18:25PM -0800, Florian Fainelli wrote:
> On 11/02/16 10:58, Bryan.Whitehead@microchip.com wrote:
> > This is the initial submission of an ethernet driver for
> > the Microchip LAN9352.
> > 
> > The LAN9352 is a 2-Port 10/100 Managed Ethernet Switch with
> > 16-Bit Non-PCI CPU Interface. The CPU interface includes a basic
> > ethernet controller interface whose virtual phy is connected
> > internally to a 3rd port on the embedded switch.
> > 
> > This driver only operates as a simple ethernet controller
> > on the CPU interface. Since this interface is connected directly
> > to the embedded switch, the result is that traffic can be sent and
> > received on both physical ports.
> 
> If this is an integrated switch, have you considered using the DSA
> subsystem and having this driver just be the Ethernet driver that
> interfaces to your CPU interface, but does not attempt to configure the
> switch in any way?

I actually think switchdev might be the better model. Hard to say. The
datasheet suggests it could be modelled as a three port switch, so DSA
might be appropriate...

      Andrew
