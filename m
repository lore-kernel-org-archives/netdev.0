From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next,V2] Add LAN9352 Ethernet Driver
Date: Wed, 17 Feb 2016 01:31:49 +0100
Message-ID: <20160217003149.GA9217@lunn.ch>
References: <20160216203625.GC2558@lunn.ch>
 <20160216.154358.164326104187806534.davem@davemloft.net>
 <90A7E81AE28BAE4CBDDB3B35F187D264402EFB5D@CHN-SV-EXMX02.mchp-main.com>
 <20160216.155244.2052910262411568012.davem@davemloft.net>
 <90A7E81AE28BAE4CBDDB3B35F187D264402EFB82@CHN-SV-EXMX02.mchp-main.com>
 <20160216221536.GB6033@lunn.ch>
 <56C3B9A2.6040401@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bryan.Whitehead@microchip.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:49683 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933422AbcBQAbx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2016 19:31:53 -0500
Content-Disposition: inline
In-Reply-To: <56C3B9A2.6040401@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Even if your driver does not support tagging

Looking at the data sheet, it looks like the hardware does support
tagging. You add an extra "VLAN" tag, whos bits have very little to do
with VLANs. So a new tag implementation will be needed, but that is
not hard.

    Andrew
