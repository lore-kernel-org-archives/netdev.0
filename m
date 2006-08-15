From: Michael Stone <mstone@mathom.us>
Subject: Re: [PATCH] mark sk98lin driver for removal
Date: Tue, 15 Aug 2006 14:42:33 -0400
Message-ID: <20060815184231.GV2900@mathom.us>
References: <20060815131852.GP2900@mathom.us>
 <20060815110340.2c60f842@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms048pub.verizon.net ([206.46.252.48]:13450 "EHLO
	vms048pub.verizon.net") by vger.kernel.org with ESMTP
	id S965096AbWHOSnH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 14:43:07 -0400
Received: from osgiliath.mathom.us ([72.66.19.42])
 by vms048.mailsrvcs.net (Sun Java System Messaging Server 6.2-4.02 (built Sep
 9 2005)) with ESMTPA id <0J410018JYN2KNI1@vms048.mailsrvcs.net> for
 netdev@vger.kernel.org; Tue, 15 Aug 2006 13:42:39 -0500 (CDT)
In-reply-to: <20060815110340.2c60f842@dxpl.pdx.osdl.net>
To: Stephen Hemminger <shemminger@osdl.org>
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 15, 2006 at 11:03:40AM -0700, Stephen Hemminger wrote:
>	* driver parameters 
>		skge/sky2 don't have many and most are standard across other drivers
>		This driver intentionally does not support configuration via module
>		parameters because it is better done through ethtool

Fair enough. It might be nice to mention that specifically somewhere, for 
people transitioning from sk98lin (which required a special parameter in 
order to use both ports).

>The driver has always supported both ports as separate devices. If you want to
>use bonding or fail over that is available in generic kernel.

ok, I'll test that in the next few days.

>> I tried testing the skge driver on one system and got this in dmesg:
>> 
>> skge 0000:03:0c.0: unsupported phy type 0x0
>> ACPI: PCI interrupt for device 0000:03:0c.0 disabled
>> skge: probe of 0000:03:0c.0 failed with error -95
>>
>
>What hardware was that? Please send me an lspci -vv output.

0000:03:0c.0 Ethernet controller: Syskonnect (Schneider & Koch) SK-98xx Gigabit Ethernet Server Adapter (rev 12)
        Subsystem: Syskonnect (Schneider & Koch) SK-9843 Gigabit Ethernet Server Adapter (SK-NET GE-SX)
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR+ FastB2B-
        Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 32 (5750ns min, 7750ns max), Cache Line Size: 0x10 (64 bytes)
        Interrupt: pin A routed to IRQ 21
        Region 0: Memory at dfddc000 (32-bit, non-prefetchable) [size=16K]
        Region 1: I/O ports at e800 [size=256]
        Expansion ROM at d8000000 [disabled] [size=128K]
        Capabilities: [48] Power Management version 1
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
                Status: D0 PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [50] Vital Product Data

Mike Stone
