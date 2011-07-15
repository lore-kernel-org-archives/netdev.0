From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: iwlagn: Random "Time out reading EEPROM".
Date: Fri, 15 Jul 2011 10:22:16 +0200
Message-ID: <4E1FF8B8.9020005@gmail.com>
References: <4DEA2FC1.2030104@gmail.com> <1307284276.6918.17.camel@wwguy-ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	wireless <linux-wireless@vger.kernel.org>
To: wwguy <wey-yi.w.guy@intel.com>, dhalperi@cs.washington.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f52.google.com ([209.85.161.52]:46627 "EHLO
	mail-fx0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965123Ab1GOIWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2011 04:22:21 -0400
In-Reply-To: <1307284276.6918.17.camel@wwguy-ubuntu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/06/2011 16:31, wwguy a =C3=A9crit :
> On Sat, 2011-06-04 at 06:14 -0700, Nicolas de Peslo=C3=BCan wrote:
>> Hi,
>>
>>   From time to time, my Intel Wifi adapter fail on cold boot, with t=
he following in dmesg:
>>
>> [    7.442634] iwlagn: Intel(R) Wireless WiFi Link AGN driver for Li=
nux, 1.3.27ks
>> [    7.442636] iwlagn: Copyright(c) 2003-2009 Intel Corporation
>> [    7.442701] iwlagn 0000:05:00.0: PCI INT A ->  GSI 18 (level, low=
) ->  IRQ 18
>> [    7.442708] iwlagn 0000:05:00.0: setting latency timer to 64
>> [    7.442788] iwlagn 0000:05:00.0: Detected Intel Wireless WiFi Lin=
k 5100AGN REV=3D0x54
>> [    7.455547] iwlagn 0000:05:00.0: Time out reading EEPROM[0]
>> [    7.455611] iwlagn 0000:05:00.0: Unable to init EEPROM
>> [    7.455678] iwlagn 0000:05:00.0: PCI INT A disabled
>> [    7.455685] iwlagn: probe of 0000:05:00.0 failed with error -110
>>
>> After "modprobe -r iwlagn ; modprobe iwlagn" or after a reboot, ever=
ything work fine:
>>
>> [  346.332166] iwlagn: Intel(R) Wireless WiFi Link AGN driver for Li=
nux, 1.3.27ks
>> [  346.332169] iwlagn: Copyright(c) 2003-2009 Intel Corporation
>> [  346.332225] iwlagn 0000:05:00.0: PCI INT A ->  GSI 18 (level, low=
) ->  IRQ 18
>> [  346.332234] iwlagn 0000:05:00.0: setting latency timer to 64
>> [  346.332277] iwlagn 0000:05:00.0: Detected Intel Wireless WiFi Lin=
k 5100AGN REV=3D0x54
>> [  346.365739] iwlagn 0000:05:00.0: Tunable channels: 13 802.11bg, 2=
4 802.11a channels
>> [  346.365787]   alloc irq_desc for 33 on node -1
>> [  346.365788]   alloc kstat_irqs on node -1
>> [  346.365804] iwlagn 0000:05:00.0: irq 33 for MSI/MSI-X
>> [  346.449989] phy0: Selected rate control algorithm 'iwl-agn-rs'
>>
>> This happens using 2.6.32-5 from Debian. I didn't had the opportunit=
y to reproduce it using recent
>> kernel, but it occurs too rarely to conclude anything.
>>
>> I had a look at the git log, without finding something that seems re=
lated to this problem. Does this
>> ring a bell for someone?
>>
>> 	Nicolas.
>>
>> 05:00.0 Network controller: Intel Corporation WiFi Link 5100
>>           Subsystem: Intel Corporation WiFi Link 5100 AGN
>>           Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop=
- ParErr- Stepping- SERR-
>> FastB2B- DisINTx-
>>           Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast>TA=
bort-<TAbort-<MAbort->SERR-
>> <PERR- INTx-
>>           Latency: 0, Cache Line Size: 64 bytes
>>           Interrupt: pin A routed to IRQ 33
>>           Region 0: Memory at d6d00000 (64-bit, non-prefetchable) [s=
ize=3D8K]
>>           Capabilities: [c8] Power Management version 3
>>                   Flags: PMEClk- DSI+ D1- D2- AuxCurrent=3D0mA PME(D=
0+,D1-,D2-,D3hot+,D3cold+)
>>                   Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D=
0 PME-
>>           Capabilities: [d0] MSI: Enable+ Count=3D1/1 Maskable- 64bi=
t+
>>                   Address: 00000000fee0300c  Data: 41c9
>>           Capabilities: [e0] Express (v1) Endpoint, MSI 00
>>                   DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency=
 L0s<512ns, L1 unlimited
>>                           ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLR=
eset+
>>                   DevCtl: Report errors: Correctable- Non-Fatal- Fat=
al- Unsupported-
>>                           RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoo=
p+ FLReset-
>>                           MaxPayload 128 bytes, MaxReadReq 128 bytes
>>                   DevSta: CorrErr+ UncorrErr- FatalErr- UnsuppReq+ A=
uxPwr+ TransPend-
>>                   LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s=
 L1, Latency L0<128ns, L1<32us
>>                           ClockPM+ Surprise- LLActRep- BwNot-
>>                   LnkCtl: ASPM L1 Enabled; RCB 64 bytes Disabled- Re=
train- CommClk+
>>                           ExtSynch- ClockPM- AutWidDis- BWInt- AutBW=
Int-
>>                   LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- Slo=
tClk+ DLActive- BWMgmt- ABWMgmt-
>>           Capabilities: [100 v1] Advanced Error Reporting
>>                   UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- U=
nxCmplt- RxOF- MalfTLP- ECRC-
>> UnsupReq- ACSViol-
>>                   UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- U=
nxCmplt- RxOF- MalfTLP- ECRC-
>> UnsupReq- ACSViol-
>>                   UESvrt: DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- U=
nxCmplt- RxOF+ MalfTLP+ ECRC-
>> UnsupReq- ACSViol-
>>                   CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout-=
 NonFatalErr+
>>                   CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout-=
 NonFatalErr+
>>                   AERCap: First Error Pointer: 00, GenCap- CGenEn- C=
hkCap- ChkEn-
>>           Capabilities: [140 v1] Device Serial Number 00-22-fb-ff-ff=
-28-46-c8
>>           Kernel driver in use: iwlagn
>>
>
> no sure, you are the ONLY one report this issue, since the device wor=
ks
> after you reload the module, the HW/SW is ok. maybe the timing/sequen=
ce
> have problem on the kernel you are using on your system. The bus is n=
ot
> ready when you boot the system and access the EEPROM.
>
> What model of the laptop you have? could you try to upgrade to newer
> kernel?

This problem also happens using 2.6.39-2-amd64 from Debian.

[    8.507426] iwlagn: Intel(R) Wireless WiFi Link AGN driver for Linux=
, in-tree:
[    8.507429] iwlagn: Copyright(c) 2003-2010 Intel Corporation
[    8.507521] iwlagn 0000:05:00.0: PCI INT A -> GSI 18 (level, low) ->=
 IRQ 18
[    8.507529] iwlagn 0000:05:00.0: setting latency timer to 64
[    8.507556] iwlagn 0000:05:00.0: Detected Intel(R) WiFi Link 5100 AG=
N, REV=3D0x54
[    8.516687] iwlagn 0000:05:00.0: Time out reading EEPROM[2]
[    8.516724] iwlagn 0000:05:00.0: Unable to init EEPROM
[    8.516739] iwlagn 0000:05:00.0: PCI INT A disabled
[    8.516745] iwlagn: probe of 0000:05:00.0 failed with error -110

modprobe -r iwlagn ; modprobe iwlagn

[  208.948664] iwlagn: Intel(R) Wireless WiFi Link AGN driver for Linux=
, in-tree:
[  208.948666] iwlagn: Copyright(c) 2003-2010 Intel Corporation
[  208.948743] iwlagn 0000:05:00.0: PCI INT A -> GSI 18 (level, low) ->=
 IRQ 18
[  208.948753] iwlagn 0000:05:00.0: setting latency timer to 64
[  208.948817] iwlagn 0000:05:00.0: Detected Intel(R) WiFi Link 5100 AG=
N, REV=3D0x54
[  208.969659] iwlagn 0000:05:00.0: device EEPROM VER=3D0x11f, CALIB=3D=
0x4
[  208.969661] iwlagn 0000:05:00.0: Device SKU: 0Xb
[  208.969701] iwlagn 0000:05:00.0: Tunable channels: 13 802.11bg, 24 8=
02.11a channels
[  208.969766] iwlagn 0000:05:00.0: irq 50 for MSI/MSI-X
[  209.048366] iwlagn 0000:05:00.0: loaded firmware version 8.83.5.1 bu=
ild 33692

Because it happens not very often, I still didn't had the opportunity t=
o reproduce it with up to=20
date kernel.

The laptop is a two years old Sony Vaio VGN-AW21M.

	Nicolas.
