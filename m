From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next,V2] Add LAN9352 Ethernet Driver
Date: Tue, 16 Feb 2016 23:15:36 +0100
Message-ID: <20160216221536.GB6033@lunn.ch>
References: <20160216203625.GC2558@lunn.ch>
 <20160216.154358.164326104187806534.davem@davemloft.net>
 <90A7E81AE28BAE4CBDDB3B35F187D264402EFB5D@CHN-SV-EXMX02.mchp-main.com>
 <20160216.155244.2052910262411568012.davem@davemloft.net>
 <90A7E81AE28BAE4CBDDB3B35F187D264402EFB82@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, f.fainelli@gmail.com, netdev@vger.kernel.org
To: Bryan.Whitehead@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47851 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756269AbcBPWPk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2016 17:15:40 -0500
Content-Disposition: inline
In-Reply-To: <90A7E81AE28BAE4CBDDB3B35F187D264402EFB82@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I just spoke with my manager, and we would like to change the target
> device from LAN9352 to LAN9250. The LAN9250 is the same as the
> LAN9352 but without the switch. It has one mac and one phy.

It is not so easy to get an overview from the website, but it looks
like:

LAN9250 - one port MAC/PHY
LAN9352 - 10/100 2-Port Managed Ethernet Switch
LAN9353 - 10/100 3-Port Managed Ethernet with Dual RMII or Single MII/RMII/Turbo MII
LAN9354 - 10/100 3-Port Managed Ethernet Switch with Single RMII
LAN9355 - 10/100 3-Port Managed Ethernet Switch with Dual MII/RMII/Turbo MII

So i get the feeling this product line is for switches, and the
LAN9250 is an oddball in the series.

You are already 1/2 way to a DSA driver, since you have a MAC
driver. So i agree with David, do it right and add a simple DSA
driver.

	Andrew
