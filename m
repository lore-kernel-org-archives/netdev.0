From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: "skge 0000:01:0a.0: unsupported phy type 0x0"
Date: Mon, 5 Mar 2007 14:13:00 -0800
Message-ID: <20070305141300.11edbc4e@freekitty>
References: <Pine.LNX.4.64.0703051346070.25740@potato.cts.ucla.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Chris Stromsoe <cbs@cts.ucla.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:38595 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750874AbXCEWNE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2007 17:13:04 -0500
In-Reply-To: <Pine.LNX.4.64.0703051346070.25740@potato.cts.ucla.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 5 Mar 2007 13:48:29 -0800 (PST)
Chris Stromsoe <cbs@cts.ucla.edu> wrote:

> I have a bunch of dual-port SK 98xx cards that work with sk98lin but not 
> with skge.  After loading skge, I get
> 
> ACPI: PCI Interrupt 0000:01:0a.0[A] -> Link [LNKC] -> GSI 10 (level, low) -> IRQ 10
> skge 0000:01:0a.0: unsupported phy type 0x0
> ACPI: PCI interrupt for device 0000:01:0a.0 disabled
> skge: probe of 0000:01:0a.0 failed with error -95
> 
> 
> lspci -vv output for the card:
> 
> 0000:01:0a.0 Ethernet controller: Syskonnect (Schneider & Koch) SK-98xx Gigabit Ethernet Server Adapter (rev 12)
>          Subsystem: Syskonnect (Schneider & Koch) SK-9844 Gigabit Ethernet Server Adapter (SK-NET GE-SX dual link)
>          Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR+ FastB2B-
>          Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>          Interrupt: pin A routed to IRQ 10
>          Region 0: Memory at ff8fc000 (32-bit, non-prefetchable) [size=16K]
>          Region 1: I/O ports at d800 [size=256]
>          Expansion ROM at ff400000 [disabled] [size=128K]
>          Capabilities: [48] Power Management version 1
>                  Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                  Status: D0 PME-Enable- DSel=0 DScale=1 PME-
>          Capabilities: [50] Vital Product Data
> 

What kernel version. Type 0 is XMAC support, and that was added to a fairly
recent kernel (2.6.19?)

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
