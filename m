From: <Bryan.Whitehead@microchip.com>
Subject: RE: [PATCH net-next,V2] Add LAN9352 Ethernet Driver
Date: Tue, 16 Feb 2016 21:32:20 +0000
Message-ID: <90A7E81AE28BAE4CBDDB3B35F187D264402EFB82@CHN-SV-EXMX02.mchp-main.com>
References: <20160216203625.GC2558@lunn.ch>
	<20160216.154358.164326104187806534.davem@davemloft.net>
	<90A7E81AE28BAE4CBDDB3B35F187D264402EFB5D@CHN-SV-EXMX02.mchp-main.com>
 <20160216.155244.2052910262411568012.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <andrew@lunn.ch>, <f.fainelli@gmail.com>, <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp03.microchip.com ([198.175.253.49]:28073 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756115AbcBPVcW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 16:32:22 -0500
In-Reply-To: <20160216.155244.2052910262411568012.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, February 16, 2016 3:53 PM
> >>
> >> I do not think, with all the infrastructure we have, that we should
> >> accept pure ethernet drivers for such devices any more.
> >>
> >> About year ago I would have responded differently, but these days all
> >> of the necessary support and infrastructure is there, and reasonable
> >> easy for driver authors to use.
> >
> > I believe I can make the physical phys accessible through ethertool. Would
> that be reasonable?
> 
> No, we are asking you to implement DSA or switchdev support.

I just spoke with my manager, and we would like to change the target device from LAN9352 to LAN9250. The LAN9250 is the same as the LAN9352 but without the switch. It has one mac and one phy. 

Since there is no switch in that product, will that make a pure Ethernet driver easier to accept?
