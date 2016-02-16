From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next,V2] Add LAN9352 Ethernet Driver
Date: Tue, 16 Feb 2016 16:38:57 -0500 (EST)
Message-ID: <20160216.163857.1276474496395829938.davem@davemloft.net>
References: <90A7E81AE28BAE4CBDDB3B35F187D264402EFB5D@CHN-SV-EXMX02.mchp-main.com>
	<20160216.155244.2052910262411568012.davem@davemloft.net>
	<90A7E81AE28BAE4CBDDB3B35F187D264402EFB82@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org
To: Bryan.Whitehead@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40483 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756067AbcBPVi6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 16:38:58 -0500
In-Reply-To: <90A7E81AE28BAE4CBDDB3B35F187D264402EFB82@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Bryan.Whitehead@microchip.com>
Date: Tue, 16 Feb 2016 21:32:20 +0000

> I just spoke with my manager, and we would like to change the target
> device from LAN9352 to LAN9250. The LAN9250 is the same as the
> LAN9352 but without the switch. It has one mac and one phy.
> 
> Since there is no switch in that product, will that make a pure
> Ethernet driver easier to accept?

I'm not going to allow you to weasel away from doing things correctly
by doing this.

You are doing this so you can still put the pure ethernet driver into
the tree, and then off-tree you'll just add the device ID for the
switch device.

Sorry, that won't pass.
