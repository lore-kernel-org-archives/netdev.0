From: Benoit Boissinot <bboissin@gmail.com>
Subject: Re: [RFT] New syskonnect gigabit ether driver (skge)
Date: Mon, 17 Jan 2005 14:35:06 +0100
Message-ID: <40f323d0050117053528f7ac8@mail.gmail.com>
Reply-To: Benoit Boissinot <bboissin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Jeff Garzik <jgarzik@pobox.com>,
        Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Here is my rewrite of the SysKonnect Gigabit Ether driver.  Gave up on
> the existing sk98lin driver because it bloated and limited by the requirement
> to be portable.  This version is still very experimental and has only been
> run for several days on my LinkSys card (single port Yukon).
> Please test on other hardware and let me know what you find out.

I had no problem with it with the following card (3Com) (not tested in
GigaEthernet mode):
(kernel 2.6.11-rc1-mm1)


0000:00:09.0 Ethernet controller: 3Com Corporation 3c940
10/100/1000Base-T [Marvell] (rev 12)
        Subsystem: ASUSTeK Computer Inc. P4P800 Mainboard
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr- Stepping- SERR- FastB2B-
        Status: Cap+ 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 32 (5750ns min, 7750ns max), cache line size 08
        Interrupt: pin A routed to IRQ 177
        Region 0: Memory at d6800000 (32-bit, non-prefetchable)
        Region 1: I/O ports at b800 [size=256]
        Capabilities: [48] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA
PME(D0+,D1+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [50] Vital Product Data
