From: Michael Stone <mstone@mathom.us>
Subject: Re: [PATCH] mark sk98lin driver for removal
Date: Thu, 17 Aug 2006 11:21:17 -0400
Message-ID: <20060817152116.GA6891@mathom.us>
References: <20060815131852.GP2900@mathom.us>
 <20060815110340.2c60f842@dxpl.pdx.osdl.net> <20060815184231.GV2900@mathom.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms042pub.verizon.net ([206.46.252.42]:59134 "EHLO
	vms042pub.verizon.net") by vger.kernel.org with ESMTP
	id S965136AbWHQPVn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 11:21:43 -0400
Received: from osgiliath.mathom.us ([72.66.19.85])
 by vms042.mailsrvcs.net (Sun Java System Messaging Server 6.2-4.02 (built Sep
 9 2005)) with ESMTPA id <0J4500EI8ENKZ695@vms042.mailsrvcs.net> for
 netdev@vger.kernel.org; Thu, 17 Aug 2006 10:21:21 -0500 (CDT)
In-reply-to: <20060815184231.GV2900@mathom.us>
To: Stephen Hemminger <shemminger@osdl.org>
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 15, 2006 at 02:42:32PM -0400, Michael Stone wrote:
>On Tue, Aug 15, 2006 at 11:03:40AM -0700, Stephen Hemminger wrote:
>>The driver has always supported both ports as separate devices. If you 
>>want to
>>use bonding or fail over that is available in generic kernel.
>
>ok, I'll test that in the next few days.

The testing didn't get far; the SK-9844 isn't supported either (same 
"unsupported phy" message). 

0000:01:06.0 Ethernet controller: Syskonnect (Schneider & Koch) SK-98xx Gigabit Ethernet Server Adapter (rev 12)
        Subsystem: Syskonnect (Schneider & Koch) SK-9844 Gigabit Ethernet Server Adapter (SK-NET GE-SX dual link)
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR+ FastB2B-
        Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 32 (5750ns min, 7750ns max), Cache Line Size: 0x10 (64 bytes)
        Interrupt: pin A routed to IRQ 20
        Region 0: Memory at fcf04000 (32-bit, non-prefetchable) [size=16K]
        Region 1: I/O ports at dc00 [size=256]
        Expansion ROM at fce00000 [disabled] [size=128K]
        Capabilities: [48] Power Management version 1
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
                Status: D0 PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [50] Vital Product Data


-- 
Michael Stone
