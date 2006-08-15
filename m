From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] mark sk98lin driver for removal
Date: Tue, 15 Aug 2006 11:03:40 -0700
Message-ID: <20060815110340.2c60f842@dxpl.pdx.osdl.net>
References: <20060815131852.GP2900@mathom.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:26559 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030416AbWHOSDr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 14:03:47 -0400
To: Michael Stone <mstone@mathom.us>
In-Reply-To: <20060815131852.GP2900@mathom.us>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 15 Aug 2006 09:18:54 -0400
Michael Stone <mstone@mathom.us> wrote:

> Hopefully the skge driver will be updated to support everything the 
> sk98lin driver does before it is removed. Among other things, I don't 
> see any documentation for the skge driver similar to that for the 
> sk98lin driver.

I don't see any need for additional documentation.
What is in sk98lin:
	* installation	--> already covered by normal kernel install
	* compiling	--> ditto
	* loading module --> ditto
	* driver parameters 
		skge/sky2 don't have many and most are standard across other drivers
		This driver intentionally does not support configuration via module
		parameters because it is better done through ethtool
			

> Is there some driver option to use both ports of a dual 
> port card, as there was for the sk98lin module?

The driver has always supported both ports as separate devices. If you want to
use bonding or fail over that is available in generic kernel.

> I tried testing the skge driver on one system and got this in dmesg:
> 
> skge 0000:03:0c.0: unsupported phy type 0x0
> ACPI: PCI interrupt for device 0000:03:0c.0 disabled
> skge: probe of 0000:03:0c.0 failed with error -95
>

What hardware was that? Please send me an lspci -vv output.
I can add support for it. I avoided adding support for all the possible
flavors because some of the variants seem to only have existed on a test bench.

> the sk98lin driver says:
> 
> eth0: SysKonnect SK-NET Gigabit Ethernet Adapter SK-9843 SX
>       PrefPort:A  RlmtMode:Check Link State
> 
> Mike Stone
