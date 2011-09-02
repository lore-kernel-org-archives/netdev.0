From: Francesco Piccinno <stack.box@gmail.com>
Subject: Re: [Bugme-new] [Bug 42132] New: Support BCM5750M in tg3
Date: Fri, 2 Sep 2011 03:14:57 +0200
Message-ID: <CAA7bCn7Au+-QEa7hTwO_P_mnL1w5TiGPz4Wsm0CxtoqT3FDBbQ@mail.gmail.com>
References: <bug-42132-10286@https.bugzilla.kernel.org/> <20110901164011.baa9a8b8.akpm@linux-foundation.org>
 <20110902000646.GA4910@mcarlson.broadcom.com> <CAA7bCn6DRmoqhHGBOAkaDqCdiYwrjPGuaYcck7n4+o3Lm10w2g@mail.gmail.com>
 <20110902010431.GA5105@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>,
	Benjamin Li <benli@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:65315 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932809Ab1IBBPh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2011 21:15:37 -0400
Received: by pzk37 with SMTP id 37so3801270pzk.1
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2011 18:15:37 -0700 (PDT)
In-Reply-To: <20110902010431.GA5105@mcarlson.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The only message I get regarding the firmware is the following:

[51503.038205] pci 0000:08:00.0: vpd r/w failed.  This is likely a
firmware bug on this device.  Contact the card vendor for a firmware
update.

Unfortunately I can not post the output of ethtool since the interface
is not available. Shall I recompile the tg3 module with the proper
patch and post the output?

--
Best regards,
=46rancesco Piccinno

On Fri, Sep 2, 2011 at 3:04 AM, Matt Carlson <mcarlson@broadcom.com> wr=
ote:
> It's showing up on lspci as a PCIe device, so it can't be the 5750M.
> The bcm5750M is a pci device.
>
> I'm wondering if bootcode is failing. =C2=A0Do you see any messages i=
n your
> syslogs that say "No firmware running"?
>
> Can you post the output of 'ethtool -i ethX'?
>
> On Thu, Sep 01, 2011 at 05:48:50PM -0700, Francesco Piccinno wrote:
>> Yes sure.
>>
>> # lspci -vvv -s 08:00.0
>> 08:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5750M
>> Gigabit Ethernet
>> =C2=A0 =C2=A0 =C2=A0 Subsystem: Broadcom Corporation NetXtreme BCM57=
50M Gigabit Ethernet
>> =C2=A0 =C2=A0 =C2=A0 Control: I/O- Mem+ BusMaster+ SpecCycle- MemWIN=
V- VGASnoop- ParErr-
>> Stepping- SERR- FastB2B- DisINTx-
>> =C2=A0 =C2=A0 =C2=A0 Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSE=
L=3Dfast >TAbort-
>> <TAbort- <MAbort- >SERR- <PERR- INTx-
>> =C2=A0 =C2=A0 =C2=A0 Latency: 0, Cache Line Size: 64 bytes
>> =C2=A0 =C2=A0 =C2=A0 Interrupt: pin A routed to IRQ 10
>> =C2=A0 =C2=A0 =C2=A0 Region 0: Memory at f4100000 (64-bit, non-prefe=
tchable) [size=3D64K]
>> =C2=A0 =C2=A0 =C2=A0 Capabilities: [48] Power Management version 2
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Flags: PMEClk- DSI-=
 D1- D2- AuxCurrent=3D0mA PME(D0-,D1-,D2-,D3hot+,D3cold+)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Status: D0 NoSoftRs=
t- PME-Enable- DSel=3D0 DScale=3D1 PME-
>> =C2=A0 =C2=A0 =C2=A0 Capabilities: [50] Vital Product Data
>> pcilib: sysfs_read_vpd: read failed: Connection timed out
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Not readable
>> =C2=A0 =C2=A0 =C2=A0 Capabilities: [58] MSI: Enable- Count=3D1/8 Mas=
kable- 64bit+
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Address: 5149526521=
410124 =C2=A0Data: 8b60
>> =C2=A0 =C2=A0 =C2=A0 Capabilities: [d0] Express (v1) Endpoint, MSI 0=
0
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 DevCap: MaxPayload =
512 bytes, PhantFunc 0, Latency L0s <4us, L1 unlimited
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 ExtTag+ AttnBtn- AttnInd- PwrInd- RBE- FLReset-
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 DevCtl: Report erro=
rs: Correctable- Non-Fatal- Fatal- Unsupported-
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 MaxPayload 128 bytes, MaxReadReq 512 bytes
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 DevSta: CorrErr- Un=
corrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LnkCap: Port #0, Sp=
eed 2.5GT/s, Width x1, ASPM L0s, Latency L0 <4us, L1 <64us
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 ClockPM- Surprise- LLActRep- BwNot-
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LnkCtl: ASPM Disabl=
ed; RCB 64 bytes Disabled- Retrain- CommClk+
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 LnkSta: Speed 2.5GT=
/s, Width x1, TrErr- Train- SlotClk+ DLActive-
>> BWMgmt- ABWMgmt-
>> =C2=A0 =C2=A0 =C2=A0 Capabilities: [100 v1] Advanced Error Reporting
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 UESta: =C2=A0DLP- S=
DES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
>> MalfTLP- ECRC- UnsupReq- ACSViol-
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 UEMsk: =C2=A0DLP- S=
DES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
>> MalfTLP- ECRC- UnsupReq- ACSViol-
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 UESvrt: DLP+ SDES- =
TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+
>> MalfTLP+ ECRC- UnsupReq- ACSViol-
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 CESta: =C2=A0RxErr-=
 BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 CEMsk: =C2=A0RxErr-=
 BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 AERCap: First Error=
 Pointer: 00, GenCap+ CGenEn- ChkCap+ ChkEn-
>> =C2=A0 =C2=A0 =C2=A0 Capabilities: [13c v1] Virtual Channel
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Caps: =C2=A0 LPEVC=3D=
0 RefClk=3D100ns PATEntryBits=3D1
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Arb: =C2=A0 =C2=A0F=
ixed- WRR32- WRR64- WRR128-
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Ctrl: =C2=A0 ArbSel=
ect=3DFixed
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Status: InProgress-
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 VC0: =C2=A0 =C2=A0C=
aps: =C2=A0 PATOffset=3D00 MaxTimeSlots=3D1 RejSnoopTrans-
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 Arb: =C2=A0 =C2=A0Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 Ctrl: =C2=A0 Enable+ ID=3D0 ArbSelect=3DFixed TC/VC=3D01
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 Status: NegoPending- InProgress-
>> =C2=A0 =C2=A0 =C2=A0 Capabilities: [160 v1] Device Serial Number 00-=
00-00-ff-fe-00-00-00
>>
>> Serial number is CND71700K6.
>> --
>> Best regards,
>> Francesco Piccinno
>>
>>
>>
>> On Fri, Sep 2, 2011 at 2:06 AM, Matt Carlson <mcarlson@broadcom.com>=
 wrote:
>> > On Thu, Sep 01, 2011 at 04:40:11PM -0700, Andrew Morton wrote:
>> >>
>> >> (switched to email. ??Please respond via emailed reply-to-all, no=
t via the
>> >> bugzilla web interface).
>> >>
>> >> On Wed, 31 Aug 2011 18:18:40 GMT
>> >> bugzilla-daemon@bugzilla.kernel.org wrote:
>> >>
>> >> > https://bugzilla.kernel.org/show_bug.cgi?id=3D42132
>> >> >
>> >> > ?? ?? ?? ?? ?? ??Summary: Support BCM5750M in tg3
>> >> > ?? ?? ?? ?? ?? ??Product: Drivers
>> >> > ?? ?? ?? ?? ?? ??Version: 2.5
>> >> > ?? ?? Kernel Version: 3.0.3
>> >> > ?? ?? ?? ?? ?? Platform: All
>> >> > ?? ?? ?? ?? OS/Version: Linux
>> >> > ?? ?? ?? ?? ?? ?? ?? Tree: Mainline
>> >> > ?? ?? ?? ?? ?? ?? Status: NEW
>> >> > ?? ?? ?? ?? ?? Severity: normal
>> >> > ?? ?? ?? ?? ?? Priority: P1
>> >> > ?? ?? ?? ?? ??Component: Network
>> >> > ?? ?? ?? ?? AssignedTo: drivers_network@kernel-bugs.osdl.org
>> >> > ?? ?? ?? ?? ReportedBy: stack.box@gmail.com
>> >> > ?? ?? ?? ?? Regression: Yes
>> >> >
>> >> >
>> >> > I have a notebook (HP TC4400) which has a BCM5750 ethernet card=
 inside. The
>> >> > ouput of lspci is:
>> >> >
>> >> > 08:00.0 Ethernet controller [0200]: Broadcom Corporation NetXtr=
eme BCM5750M
>> >> > Gigabit Ethernet [14e4:167c]
>> >> >
>> >> > Commit 67b284d476bcb3d100e946da23d6cf9acfd0465c removed the sup=
port for this
>> >> > device.
>> >> >
>> >>
>> >> 67b284d476bcb3d100 says "These devices were never released to the=
 public".
>> >>
>> >> > I wish to have the support for this network card back again. Th=
anks!
>> >>
>> >> oops ;)
>> >
>> > Really? ??All the TC4400 documentation I find says it uses a bcm57=
53M on a
>> > PCIe bus. ??Can you post the full output of 'lspci -vvv -s 08:00.0=
' ?
>> >
>> >
>>
>
>
