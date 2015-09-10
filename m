From: Ben Pope <benpope81@gmail.com>
Subject: Re: [PATCH] alx: Add the Device ID for the Killer E2400
Date: Thu, 10 Sep 2015 08:42:59 +0800
Message-ID: <55F0D213.2070101@gmail.com>
References: <1441732050-7005-1-git-send-email-benpope81@gmail.com>
 <20150909.124437.2066417848362699199.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jcliburn@gmail.com, netdev@vger.kernel.org, ben@pope.name
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:36459 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751829AbbIJAnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 20:43:03 -0400
Received: by padhk3 with SMTP id hk3so25051164pad.3
        for <netdev@vger.kernel.org>; Wed, 09 Sep 2015 17:43:02 -0700 (PDT)
In-Reply-To: <20150909.124437.2066417848362699199.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, September 10, 2015 03:44 AM, David Miller wrote:
> That's a rather rediculous Subject line, you'll need to fix that
> before anyone will consider your submission seriously.

My apologies, first time user of git-send-email, I should have just sent 
it to myself as a test.

The body was supposed to include the following lspci -vv output in case 
it was useful:

03:00.0 Ethernet controller: Qualcomm Atheros Device e0a1 (rev 10)
     Subsystem: Micro-Star International Co., Ltd. [MSI] Device 7977
     Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
     Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Latency: 0
     Interrupt: pin A routed to IRQ 325
     Region 0: Memory at dfc00000 (64-bit, non-prefetchable) [size=256K]
     Region 2: I/O ports at d000 [size=128]
     Capabilities: [40] Power Management version 3
         Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA 
PME(D0+,D1+,D2+,D3hot+,D3cold+)
         Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
     Capabilities: [58] Express (v1) Endpoint, MSI 00
         DevCap:    MaxPayload 4096 bytes, PhantFunc 0, Latency L0s 
unlimited, L1 unlimited
             ExtTag- AttnBtn+ AttnInd+ PwrInd+ RBE+ FLReset-
         DevCtl:    Report errors: Correctable+ Non-Fatal+ Fatal+ 
Unsupported+
             RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
             MaxPayload 256 bytes, MaxReadReq 512 bytes
         DevSta:    CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ 
TransPend-
         LnkCap:    Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit 
Latency L0s unlimited, L1 unlimited
             ClockPM+ Surprise- LLActRep- BwNot-
         LnkCtl:    ASPM Disabled; RCB 64 bytes Disabled- CommClk+
             ExtSynch- ClockPM+ AutWidDis- BWInt- AutBWInt-
         LnkSta:    Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ 
DLActive- BWMgmt- ABWMgmt-
     Capabilities: [c0] MSI: Enable+ Count=1/16 Maskable+ 64bit+
         Address: 00000000fee0200c  Data: 4192
         Masking: 0000fffe  Pending: 00000000
     Capabilities: [d8] MSI-X: Enable- Count=16 Masked-
         Vector table: BAR=0 offset=00002000
         PBA: BAR=0 offset=00003000
     Capabilities: [100 v1] Advanced Error Reporting
         UESta:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- 
RxOF- MalfTLP- ECRC- UnsupReq+ ACSViol-
         UEMsk:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- 
RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
         UESvrt:    DLP- SDES+ TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- 
RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
         CESta:    RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
         CEMsk:    RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
         AERCap:    First Error Pointer: 14, GenCap+ CGenEn- ChkCap+ ChkEn-
     Kernel driver in use: alx


Ben
