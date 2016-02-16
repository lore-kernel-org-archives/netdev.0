From: <Bryan.Whitehead@microchip.com>
Subject: RE: [PATCH net-next,V2] Add LAN9352 Ethernet Driver
Date: Tue, 16 Feb 2016 21:37:40 +0000
Message-ID: <90A7E81AE28BAE4CBDDB3B35F187D264402EFB92@CHN-SV-EXMX02.mchp-main.com>
References: <20160212171829.GD13273@lunn.ch>
 <90A7E81AE28BAE4CBDDB3B35F187D264402EFB12@CHN-SV-EXMX02.mchp-main.com>
 <20160216203625.GC2558@lunn.ch>
 <20160216.154358.164326104187806534.davem@davemloft.net>
 <90A7E81AE28BAE4CBDDB3B35F187D264402EFB5D@CHN-SV-EXMX02.mchp-main.com>
 <20160216205756.GD2558@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <f.fainelli@gmail.com>,
	<netdev@vger.kernel.org>
To: <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp03.microchip.com ([198.175.253.49]:37211 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751375AbcBPVhl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 16:37:41 -0500
In-Reply-To: <20160216205756.GD2558@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Tuesday, February 16, 2016 3:58 PM 
> > I believe I can make the physical phys accessible through ethertool.
> > Would that be reasonable?
> 
> How, you have no netdev to attach them to?
> 
> There was a nice presentation at netdev last week by Mellanox about their
> switches. I don't know if the video is available yet, but that shows the correct
> way to do this.
> 

You are right. I misunderstood how ethtool works.

Again, I'd like to change our target device to LAN9250, which is just an Ethernet controller with no switch. 

Will a driver for that device be more easily accepted?
