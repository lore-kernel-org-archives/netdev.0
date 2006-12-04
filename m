From: Robert Martin <robertm83@gmail.com>
Subject: Re: NETDEV-BCM43XX BUG - Failure to associate AP with latest	devscape
 git pull..
Date: Mon, 04 Dec 2006 13:17:15 -0500
Message-ID: <4574662B.8000903@gmail.com>
References: <45733FBF.5020800@gmail.com> <1165221950.5553.49.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.237]:11011 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936571AbWLEARS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 19:17:18 -0500
Received: by wx-out-0506.google.com with SMTP id h27so3954178wxd
        for <netdev@vger.kernel.org>; Mon, 04 Dec 2006 16:17:17 -0800 (PST)
To: netdev@vger.kernel.org
In-Reply-To: <1165221950.5553.49.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've only had the laptop (Compaq V6000Z series) for about a week, so I'd 
be unable to tell you if the driver had worked before, but I seem to 
have had the same problem that Paul Collins did pertaining to frequency 
mismatch.  Setting it manually to the value "iwlist" gave me for the AP 
makes it work, albeit at very slow speeds (driver issue?).  I might have 
been mistaken about the PCI-E, the lspci -n gives me...

03:00.0 0280: 14e4:4311 (rev 01)

...and lspci -vvv gives me...

03:00.0 Network controller: Broadcom Corporation Dell Wireless 1390 WLAN 
Mini-PCI Card (rev 01)
       Subsystem: Hewlett-Packard Company Unknown device 1363
       Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- 
ParErr- Stepping- SERR+ FastB2B-
       Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
       Latency: 0, Cache Line Size: 64 bytes
       Interrupt: pin A routed to IRQ 22
       Region 0: Memory at b3200000 (32-bit, non-prefetchable) [size=16K]
       Capabilities: [40] Power Management version 2
               Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA 
PME(D0-,D1-,D2-,D3hot-,D3cold-)
               Status: D0 PME-Enable- DSel=0 DScale=2 PME-
       Capabilities: [58] Message Signalled Interrupts: 64bit- Queue=0/0 
Enable-
               Address: 00000000  Data: 0000
       Capabilities: [d0] Express Legacy Endpoint IRQ 0
               Device: Supported: MaxPayload 128 bytes, PhantFunc 0, 
ExtTag+
               Device: Latency L0s <4us, L1 unlimited
               Device: AtnBtn- AtnInd- PwrInd-
               Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
               Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
               Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
               Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s, Port 0
               Link: Latency L0s <4us, L1 <64us
               Link: ASPM Disabled RCB 64 bytes CommClk- ExtSynch-
               Link: Speed 2.5Gb/s, Width x1
       Capabilities: [100] Advanced Error Reporting
       Capabilities: [13c] Virtual Channel

...although I could have sworn I read somewhere that this series uses 
the PCI-E mini bus.  Thank you for your time.


Johannes Berg wrote:
> On Sun, 2006-12-03 at 16:21 -0500, Robert Martin wrote:
>
>   
>> I would be happy to give more 
>> information if requested, or try different kernel/firmware options.
>>     
>
> Has it ever worked? I'm curious because the PCI-E chips are 4318s which
> are known to not work properly due to missing/wrong TX power
> calibration.
>
> johannes
>   

