From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.26/tg3 ping roundtrip times > 2000 ms on local network
Date: Tue, 19 Aug 2008 13:20:40 -0700 (PDT)
Message-ID: <20080819.132040.188336475.davem@davemloft.net>
References: <20080819172019.GA5823@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mh+linux-kernel@zugschlus.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759431AbYHSUU4@vger.kernel.org>
In-Reply-To: <20080819172019.GA5823@torres.zugschlus.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marc Haber <mh+linux-kernel@zugschlus.de>
Date: Tue, 19 Aug 2008 19:20:19 +0200

[ netdev added to CC: ]

> I have one HP DL 140 G1 running with Debian stable and a
> locally-built, vanilla kernel. With 2.6.25.11, everything is fine.
> 
> But, after updating to 2.6.26.2, I noticed that pinging the host on
> the local ethernet sometimes (e.g. several times a minute, but not
> always) results in a round-trip time of larger than two seconds. The
> packets are not lost though, they're only severly delayed. For an ssh
> session to the host, this feels like somebody rocking a bad network
> connector. The same behavior is visible with 2.6.26 and 2.6.26.1.
> 
> Going back to 2.6.25.11 immediately fixes the issue for me.
> 
> Syslog doesn't say anything conspicious, unfortunately. As I don't
> have local access to the box, I cannot say whether it's only the
> network that freezes or whether it's the entire box.
> 
> Does it make sense to test any later 2.6.25.x kernel, or is there any
> post-2.6.26 patch available that may fix the issue for me?
> 
> Strangely, another DL 140 from the same charge runs just fine with
> 2.6.26.2.
> 
> Here is the output of lspci -vvv for the network interface:
> 
> 02:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5704 Gigabit Ethernet (rev 02)
>         Subsystem: Broadcom Corporation NetXtreme BCM5704 Gigabit Ethernet
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
>         Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 64 (16000ns min), Cache Line Size: 64 bytes
>         Interrupt: pin A routed to IRQ 19
>         Region 0: Memory at febc0000 (64-bit, non-prefetchable) [size=64K]
>         Region 2: Memory at febb0000 (64-bit, non-prefetchable) [size=64K]
>         Expansion ROM at <ignored> [disabled]
>         Capabilities: [40] PCI-X non-bridge device
>                 Command: DPERE- ERO- RBC=2048 OST=1
>                 Status: Dev=02:00.0 64bit+ 133MHz+ SCD- USC- DC=simple DMMRBC=2048 DMOST=1 DMCRS=16 RSCEM- 266MHz- 533MHz-
>         Capabilities: [48] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 PME-Enable+ DSel=0 DScale=1 PME-
>         Capabilities: [50] Vital Product Data
>         Capabilities: [58] Message Signalled Interrupts: Mask- 64bit+ Queue=0/3 Enable-
>                 Address: 1502da2a94a95200  Data: 3ca4
> 
> If there is any information that can help, please say so.
> 
> Greetings
> Marc
> 
> -- 
> -----------------------------------------------------------------------------
> Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
> Mannheim, Germany  |  lose things."    Winona Ryder | Fon: *49 621 72739834
> Nordisch by Nature |  How to make an American Quilt | Fax: *49 3221 2323190
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
