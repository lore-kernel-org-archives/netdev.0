From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next,V2] Add LAN9352 Ethernet Driver
Date: Tue, 16 Feb 2016 21:36:25 +0100
Message-ID: <20160216203625.GC2558@lunn.ch>
References: <90A7E81AE28BAE4CBDDB3B35F187D264402EF4A2@CHN-SV-EXMX02.mchp-main.com>
 <56BD40F1.2030707@gmail.com>
 <20160212072040.GC8046@lunn.ch>
 <90A7E81AE28BAE4CBDDB3B35F187D264402EF5BB@CHN-SV-EXMX02.mchp-main.com>
 <20160212171829.GD13273@lunn.ch>
 <90A7E81AE28BAE4CBDDB3B35F187D264402EFB12@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, davem@davemloft.net, netdev@vger.kernel.org
To: Bryan.Whitehead@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47747 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932189AbcBPUg2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2016 15:36:28 -0500
Content-Disposition: inline
In-Reply-To: <90A7E81AE28BAE4CBDDB3B35F187D264402EFB12@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 16, 2016 at 07:41:46PM +0000, Bryan.Whitehead@microchip.com wrote:
> Andrew,
> 
> At this point, I am not tasked with implementing switch features,
> which would likely take a long time to complete.

So this is the discussion we need to have.

The interface to the outside work is the two switch ports with real
PHYs. What you are implementing is an Ethernet driver for an internal
port connected to the switch. This port does not go to the outside
world. This driver provides no way to control the ports to the outside
world and you have no short term plan to actually implement control of
the ports connected to the outside world.

Should the Linux community accept this driver in this state?

I would prefer to see a simple switchdev or DSA driver which exposes
the two external ports.

    Andrew
