From: Michal Schmidt <xschmi00@stud.feec.vutbr.cz>
Subject: Re: [RFT] New syskonnect gigabit ether driver (skge)
Date: Mon, 17 Jan 2005 22:07:07 +0100
Message-ID: <41EC28FB.3040904@stud.feec.vutbr.cz>
References: <20050114155613.3c68e829@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Christoph Hellwig <hch@infradead.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050114155613.3c68e829@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Here is my rewrite of the SysKonnect Gigabit Ether driver.  Gave up on
> the existing sk98lin driver because it bloated and limited by the requirement
> to be portable.  This version is still very experimental and has only been
> run for several days on my LinkSys card (single port Yukon).
> Please test on other hardware and let me know what you find out.

Works with no problems with the integrated card on my Asus A8V Deluxe 
motherboard (architecture is x86_64). I only tested 100Mbit full-duplex.

0000:00:0a.0 Ethernet controller: Marvell Technology Group Ltd. Yukon 
Gigabit Ethernet 10/100/1000Base-T Adapter (rev 13)
	Subsystem: Asustek Computer, Inc.: Unknown device 811a
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- 
Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 64 (5750ns min, 7750ns max), Cache Line Size: 0x08 (32 bytes)
	Interrupt: pin A routed to IRQ 17
	Region 0: Memory at fb900000 (32-bit, non-prefetchable) [size=16K]
	Region 1: I/O ports at 9800 [size=256]
	Expansion ROM at fb800000 [disabled] [size=128K]
	Capabilities: [48] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [50] Vital Product Data
