From: Willy Tarreau <w@1wt.eu>
Subject: Re: BUG - 2.4.37 fealnx.c NETDEV WATCHDOG: eth0: transmit timed out
Date: Fri, 2 Jan 2009 15:48:13 +0100
Message-ID: <20090102144813.GA13757@1wt.eu>
References: <3f9a31f40901020640m4a9a63caq9c96ba84ccd64d88@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: wtarreau-Dj75qbTlC0E76Z2rM5mHXA@public.gmane.org, kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jaswinder Singh Rajput <jaswinderlinux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <3f9a31f40901020640m4a9a63caq9c96ba84ccd64d88-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello,

On Fri, Jan 02, 2009 at 08:10:50PM +0530, Jaswinder Singh Rajput wrote:
> Hello all,
> 
> Now I tested fealnx driver from 2.4.37 (2.4 git). I am still getting
> "NETDEV WATCHDOG: eth0: transmit timed out". Please let me know how
> can I fix this problem.

Well, I don't have such an adapter, but most of the times I encountered
a similar message with older 10/100 adapters, it was caused by a link
status issue or duplex mismatch.

Could you check with ethtool or mii-diag that the link status is correct
and 100 Mbps/Full duplex (assuming you're connected to a switch) ?

> fealnx.c:v2.51 Nov-17-2001
> eth0: 100/10M Ethernet PCI Adapter at 0x6200, 00:40:95:78:05:73, IRQ 11.
> 
> NETDEV WATCHDOG: eth0: transmit timed out
> eth0: Transmit timed out, status 00000000, resetting...
>   Rx ring c11bf000:  80000000 80000000 80000000 80000000 80000000
> 80000000 80000000 80000000 80000000 80000000 80000000 80000000
>   Tx ring c11be000:  80000000 80000000 80000000 80000000 0000 80000000
> NETDEV WATCHDOG: eth0: transmit timed out
> eth0: Transmit timed out, status 00000000, resetting...
>   Rx ring c11bf000:  80000000 80000000 80000000 80000000 80000000
> 80000000 80000000 80000000 80000000 80000000 80000000 80000000
>   Tx ring c11be000:  80000000 0000 80000000 80000000 80000000 80000000
> NETDEV WATCHDOG: eth0: transmit timed out
> eth0: Transmit timed out, status 00000000, resetting...
>   Rx ring c11bf000:  80000000 80000000 80000000 80000000 80000000
> 80000000 80000000 80000000 80000000 80000000 80000000 80000000
>   Tx ring c11be000:  80000000 80000000 80000000 80000000 80000000 0000
> 
> 
> 00:0a.0 Ethernet controller: MYSON Technology Inc: Unknown device 0803
> 	Subsystem: MYSON Technology Inc: Unknown device 0803
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B-
> 	Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR-
> 	Latency: 32 (8000ns min, 16000ns max), cache line size 08
> 	Interrupt: pin A routed to IRQ 11
> 	Region 0: I/O ports at 6200 [size=256]
> 	Region 1: Memory at e1000000 (32-bit, non-prefetchable) [size=1K]
> 	Expansion ROM at <unassigned> [disabled] [size=64K]
> 	Capabilities: [88] Power Management version 2
> 		Flags: PMEClk- DSI- D1+ D2- AuxCurrent=375mA PME(D0-,D1+,D2-,D3hot+,D3cold+)
> 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 
> Thank you,
> JSR

Regards,
Willy
