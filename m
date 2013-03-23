From: rebelyouth <rebelyouth.hacklab@gmail.com>
Subject: Re: Atheros Communications Inc. AR8121/AR8113/AR8114 Gigabit or Fast
 Ethernet (rev b0) 1.0.0.7 md5/sha1 corrupted using NFS and samba (updated)
 Version 2
Date: Fri, 22 Mar 2013 20:07:22 -0400
Message-ID: <514CF23A.3010702@gmail.com>
References: <514CE440.3010003@gmail.com> <1363996448.4431.73.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f180.google.com ([209.85.210.180]:52862 "EHLO
	mail-ia0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422650Ab3CWAH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 20:07:27 -0400
Received: by mail-ia0-f180.google.com with SMTP id f27so4089927iae.11
        for <netdev@vger.kernel.org>; Fri, 22 Mar 2013 17:07:26 -0700 (PDT)
In-Reply-To: <1363996448.4431.73.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/03/13 07:54 PM, Eric Dumazet wrote:
> On Fri, 2013-03-22 at 19:07 -0400, rebelyouth wrote:
>> Hi,
>>
>> I'm writing again for the same issue about :
>>
> Your mail is so long that we are lost.
>
> Have you done some research to tell if the bug is :
>
> 1) Sending corrupt frames
>
> 2) receive corrupt frames
>
>
Hi Eric and Hannes,

The server receiver errors  when I use the atheros:

RX packets:78125369 errors:58741 dropped:0 overruns:58741 frame:0

but on the client side  there aren't any error but the file  is corrupted

I rebooted  the server and did the test with the Realtek:

  file ok , no errors in both sides

I also reset again the server and did a test on windows using samba and 
the Atheros:

  file ok , no errors in both sides

my lspci -vv

03:00.0 Ethernet controller: Atheros Communications Inc. 
AR8121/AR8113/AR8114 Gigabit or Fast Ethernet (rev b0)
         Subsystem: ASUSTeK Computer Inc. Device 831c
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- 
ParErr- Stepping- SERR+ FastB2B- DisINTx+
         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
         Latency: 0, Cache Line Size: 64 bytes
         Interrupt: pin A routed to IRQ 47
         Region 0: Memory at fbfc0000 (64-bit, non-prefetchable) [size=256K]
         Region 2: I/O ports at ec00 [size=128]
         Capabilities: [40] Power Management version 2
                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA 
PME(D0-,D1-,D2-,D3hot+,D3cold+)
                 Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
         Capabilities: [48] MSI: Enable+ Count=1/1 Maskable- 64bit+
                 Address: 00000000fee0f00c  Data: 4142
         Capabilities: [58] Express (v1) Endpoint, MSI 00
                 DevCap: MaxPayload 4096 bytes, PhantFunc 0, Latency L0s 
<4us, L1 unlimited
                         ExtTag- AttnBtn+ AttnInd+ PwrInd+ RBE- FLReset-
                 DevCtl: Report errors: Correctable- Non-Fatal- Fatal- 
Unsupported-
                         RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
                         MaxPayload 128 bytes, MaxReadReq 512 bytes
                 DevSta: CorrErr- UncorrErr+ FatalErr- UnsuppReq+ 
AuxPwr+ TransPend-
                 LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s, 
Latency L0 unlimited, L1 unlimited
                         ClockPM- Surprise- LLActRep- BwNot-
                 LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- 
CommClk+
                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                 LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ 
DLActive- BWMgmt- ABWMgmt-
         Capabilities: [100 v1] Advanced Error Reporting
                 UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- 
UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq+ ACSViol-
                 UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- 
UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                 UESvrt: DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- 
UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
                 CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- 
NonFatalErr-
                 CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- 
NonFatalErr-
                 AERCap: First Error Pointer: 14, GenCap+ CGenEn- 
ChkCap+ ChkEn-
         Capabilities: [180 v1] Device Serial Number ff-62-72-f5-00-26-18-ff


and for the ASPM:

[    0.407310] pci 0000:03:00.0: disabling ASPM on pre-1.1 PCIe device.  
You can enable it with 'pcie_aspm=force'
[    0.407800]  pci0000:00: ACPI _OSC support notification failed, 
disabling PCIe ASPM
