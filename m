From: Christoph Hellwig <hch@lst.de>
Subject: Re: Debian #240812 - tg3 problems with NFS
Date: Thu, 19 Aug 2004 19:06:19 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040819170619.GA28226@lst.de>
References: <20040819161933.GA27114@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, stigge@antcom.de
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
In-Reply-To: <20040819161933.GA27114@lst.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Sorry, should have Cc'ed netdev and the submitter


On Thu, Aug 19, 2004 at 06:19:33PM +0200, Christoph Hellwig wrote:
> Hi Dave,
> 
> I got the following report from Roland Stigge. He later mentioned 2.6.7
> still has this issue.  There's also a full trail of the Debian bug at
> http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=240812, but because
> some zealots abused it as flameware about firmware inside drivers that
> one is pretty much useless.
> 
> ----------------------------------------------------------------------------
> Hi,
> 
> I always needed to use the separate driver from the bcm5700-source
> package for my NIC. tg3 from the current 2.6.4 kernel only works to a
> certain extent. I can browse the web (-> HTTP, DNS), ping etc. But NFS
> doesn't work. When I mount something, I get the following syslog lines:
> 
> =============================================================================
> Mar 29 13:23:13 atari kernel: nfs warning: mount version older than kernel
> Mar 29 13:24:30 atari kernel: nfs: server sbo not responding, still trying
> =============================================================================
> 
> Please note that I get the first line also with bcm5700. The second
> line doesn't appear before the volume is already mounted and I cd'd to a
> directory inside it. An "ls" makes the second line appear after some
> seconds, and the terminal with the "ls" hangs without printing anything
> further.
> 
> The attachments in this mail show the kern.log for the bcm5700 and tg3
> case.
> 
> "lspci -vv" says the following:
> =============================================================================
> [...]
> 0000:02:05.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5702 Gigabit Ethernet (rev 02)
> 	Subsystem: Asustek Computer, Inc.: Unknown device 80a9
> 	Control: I/O- Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B-
> 	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> 	Latency: 64 (16000ns min), Cache Line
> 	Size: 0x10 (64 bytes)
> 	Interrupt: pin A routed to IRQ 18
> 	Region 0: Memory at ed800000 (64-bit, non-prefetchable)
> 	[disabled] [size=f1e70000]
> 	Expansion ROM at 00010000 [disabled]
> 	Capabilities: [40] PCI-X non-bridge device.
> 		Command: DPERE- ERO- RBC=0 OST=0
> 		Status: Bus=255 Dev=31 Func=1 64bit+ 133MHz+ SCD- USC-, DC=simple, DMMRBC=2, DMOST=0, DMCRS=1, RSCEM-
> 	Capabilities: [48] Power Management version 2
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 PME-Enable+ DSel=0 DScale=1 PME-
> 	Capabilities: [50] Vital Product Data
> 	Capabilities: [58] Message Signalled Interrupts: 64bit+ Queue=0/3 Enable-
> 		Address: dfffffbfedfffcfc  Data: fdff
> [...]
> =============================================================================
> 
> bootlog for the bcm5700 driver is at:
> http://bugs.debian.org/cgi-bin/bugreport.cgi/kern.log.bcm5700?bug=240812&msg=6&att=1
> 
> bootlog for tg3 is at:
> http://bugs.debian.org/cgi-bin/bugreport.cgi/kern.log.tg3?bug=240812&msg=6&att=2
> 
---end quoted text---
