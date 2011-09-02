From: Francesco Piccinno <stack.box@gmail.com>
Subject: Re: [Bugme-new] [Bug 42132] New: Support BCM5750M in tg3
Date: Fri, 2 Sep 2011 02:48:50 +0200
Message-ID: <CAA7bCn6DRmoqhHGBOAkaDqCdiYwrjPGuaYcck7n4+o3Lm10w2g@mail.gmail.com>
References: <bug-42132-10286@https.bugzilla.kernel.org/> <20110901164011.baa9a8b8.akpm@linux-foundation.org>
 <20110902000646.GA4910@mcarlson.broadcom.com>
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
Received: from mail-pz0-f42.google.com ([209.85.210.42]:39239 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932747Ab1IBAtb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2011 20:49:31 -0400
Received: by pzk37 with SMTP id 37so3774043pzk.1
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2011 17:49:31 -0700 (PDT)
In-Reply-To: <20110902000646.GA4910@mcarlson.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes sure.

# lspci -vvv -s 08:00.0
08:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5750M
Gigabit Ethernet
	Subsystem: Broadcom Corporation NetXtreme BCM5750M Gigabit Ethernet
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 10
	Region 0: Memory at f4100000 (64-bit, non-prefetchable) [size=3D64K]
	Capabilities: [48] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0-,D1-,D2-,D3hot+,D=
3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D1 PME-
	Capabilities: [50] Vital Product Data
pcilib: sysfs_read_vpd: read failed: Connection timed out
		Not readable
	Capabilities: [58] MSI: Enable- Count=3D1/8 Maskable- 64bit+
		Address: 5149526521410124  Data: 8b60
	Capabilities: [d0] Express (v1) Endpoint, MSI 00
		DevCap:	MaxPayload 512 bytes, PhantFunc 0, Latency L0s <4us, L1 unlim=
ited
			ExtTag+ AttnBtn- AttnInd- PwrInd- RBE- FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s, Latency L0 <4us, =
L1 <64us
			ClockPM- Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive-
BWMgmt- ABWMgmt-
	Capabilities: [100 v1] Advanced Error Reporting
		UESta:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
MalfTLP- ECRC- UnsupReq- ACSViol-
		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
MalfTLP- ECRC- UnsupReq- ACSViol-
		UESvrt:	DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+
MalfTLP+ ECRC- UnsupReq- ACSViol-
		CESta:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
		AERCap:	First Error Pointer: 00, GenCap+ CGenEn- ChkCap+ ChkEn-
	Capabilities: [13c v1] Virtual Channel
		Caps:	LPEVC=3D0 RefClk=3D100ns PATEntryBits=3D1
		Arb:	Fixed- WRR32- WRR64- WRR128-
		Ctrl:	ArbSelect=3DFixed
		Status:	InProgress-
		VC0:	Caps:	PATOffset=3D00 MaxTimeSlots=3D1 RejSnoopTrans-
			Arb:	Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable+ ID=3D0 ArbSelect=3DFixed TC/VC=3D01
			Status:	NegoPending- InProgress-
	Capabilities: [160 v1] Device Serial Number 00-00-00-ff-fe-00-00-00

Serial number is CND71700K6.
--
Best regards,
=46rancesco Piccinno



On Fri, Sep 2, 2011 at 2:06 AM, Matt Carlson <mcarlson@broadcom.com> wr=
ote:
> On Thu, Sep 01, 2011 at 04:40:11PM -0700, Andrew Morton wrote:
>>
>> (switched to email. =C2=A0Please respond via emailed reply-to-all, n=
ot via the
>> bugzilla web interface).
>>
>> On Wed, 31 Aug 2011 18:18:40 GMT
>> bugzilla-daemon@bugzilla.kernel.org wrote:
>>
>> > https://bugzilla.kernel.org/show_bug.cgi?id=3D42132
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Summary: Support BCM5750M=
 in tg3
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Product: Drivers
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Version: 2.5
>> > =C2=A0 =C2=A0 Kernel Version: 3.0.3
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Platform: All
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 OS/Version: Linux
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Tree: Mainline
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Status: NEW
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Severity: normal
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Priority: P1
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Component: Network
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 AssignedTo: drivers_network@kernel-bug=
s.osdl.org
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 ReportedBy: stack.box@gmail.com
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 Regression: Yes
>> >
>> >
>> > I have a notebook (HP TC4400) which has a BCM5750 ethernet card in=
side. The
>> > ouput of lspci is:
>> >
>> > 08:00.0 Ethernet controller [0200]: Broadcom Corporation NetXtreme=
 BCM5750M
>> > Gigabit Ethernet [14e4:167c]
>> >
>> > Commit 67b284d476bcb3d100e946da23d6cf9acfd0465c removed the suppor=
t for this
>> > device.
>> >
>>
>> 67b284d476bcb3d100 says "These devices were never released to the pu=
blic".
>>
>> > I wish to have the support for this network card back again. Thank=
s!
>>
>> oops ;)
>
> Really? =C2=A0All the TC4400 documentation I find says it uses a bcm5=
753M on a
> PCIe bus. =C2=A0Can you post the full output of 'lspci -vvv -s 08:00.=
0' ?
>
>
