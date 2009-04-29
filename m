From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.30-rc3, forcedeth: no net
Date: Tue, 28 Apr 2009 20:22:59 -0700
Message-ID: <20090428202259.ede11021.akpm@linux-foundation.org>
References: <49F2D0B1.6030800@t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Ayaz Abdulla <aabdulla@nvidia.com>
To: Harald Dunkel <harald.dunkel@t-online.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753955AbZD2DZi@vger.kernel.org>
In-Reply-To: <49F2D0B1.6030800@t-online.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(cc's added)

Thanks, but please do attempt to cc the relevant mailing list and
developer on bug reports.

On Sat, 25 Apr 2009 10:58:25 +0200 Harald Dunkel <harald.dunkel@t-online.de> wrote:

> Hi folks,
> 
> There is a problem with forcedeth: The initialization on my
> machine takes several minutes. This exceeds the usual wait
> loop of dhcpcd. Using a static IP address doesn't help, either.
> IP address and so on are set correctly, but there is still
> no net.
> 
> I could reproduce this with 2.6.29.1 and 2.6.30-rc3. For
> testing I had reverted cb52deba12f27af90a46d2f8667a64888118a888
> ("power down phy when interface is down"), but this did not help.
> It was a wild guess, anyway.
> 
> /var/log/messages:
> :
> :
> Apr 25 10:29:53 elmer kernel: [    5.796093] forcedeth: Reverse Engineered nForce ethernet driver. Version 0.64.
> Apr 25 10:29:53 elmer kernel: [    5.908812] ACPI: PCI Interrupt Link [LMAC] enabled at IRQ 22
> Apr 25 10:29:53 elmer kernel: [    5.944151] forcedeth 0000:00:0a.0: PCI INT A -> Link[LMAC] -> GSI 22 (level, low) -> IRQ 22
> Apr 25 10:29:53 elmer kernel: [    6.056607] forcedeth 0000:00:0a.0: ifname eth0, PHY OUI 0x732 @ 1, addr 00:22:68:62:c1:8d
> Apr 25 10:29:53 elmer kernel: [    6.075176] usbcore: registered new interface driver usbfs
> Apr 25 10:29:53 elmer kernel: [    6.154910] forcedeth 0000:00:0a.0: highdma csum pwrctl gbit lnktim msi desc-v3
> :
> :
> Apr 25 10:29:54 elmer kernel: [   22.422017] eth0: no link during initialization.
> Apr 25 10:29:54 elmer kernel: [   24.774868] eth0: link up.
> Apr 25 10:29:54 elmer kernel: [   24.780817] eth0: link down.
> Apr 25 10:29:54 elmer kernel: [   31.401174] eth0: link up.
> Apr 25 10:29:54 elmer kernel: [   33.169139] eth0: link down.
> Apr 25 10:29:54 elmer kernel: [   38.006407] eth0: link up.
> Apr 25 10:29:54 elmer kernel: [   38.011970] eth0: link down.
> Apr 25 10:31:58 elmer kernel: [  216.027643] eth0: link up.
> :
> 
> lspci:
> 00:0a.0 Ethernet controller: nVidia Corporation MCP79 Ethernet (rev b1)
>         Subsystem: Acer Incorporated [ALI] Device 0222
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0 (250ns min, 5000ns max)
>         Interrupt: pin A routed to IRQ 22
>         Region 0: Memory at fae7d000 (32-bit, non-prefetchable) [size=4K]
>         Region 1: I/O ports at d080 [size=8]
>         Region 2: Memory at fae7e800 (32-bit, non-prefetchable) [size=256]
>         Region 3: Memory at fae7e400 (32-bit, non-prefetchable) [size=16]
>         Capabilities: [44] Power Management version 2
>                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
>                 Status: D0 PME-Enable+ DSel=0 DScale=0 PME-
>         Kernel driver in use: forcedeth
> 
> The machine is an Acer Aspire Revo.
> 
> I would be glad to help to debug this problem. Please mail.
> 
