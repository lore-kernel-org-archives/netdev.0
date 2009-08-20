From: =?iso-8859-15?Q?Beno=EEt?= Vaillant <benoit.vaillant@no-log.org>
Subject: Re: sd8686 linux system hang: not always
Date: Thu, 20 Aug 2009 22:40:51 +0200
Message-ID: <20090820204051.GA24491@kaos.fbx.proxad.net>
References: <20090819185605.GA19345@kaos.fbx.proxad.net>
 <1250710797.5351.89.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="0eh6TmSyL6TZE2Uz"
Cc: netdev@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:58081 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754504AbZHTUkc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Aug 2009 16:40:32 -0400
Content-Disposition: inline
In-Reply-To: <1250710797.5351.89.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--0eh6TmSyL6TZE2Uz
Content-Type: multipart/mixed; boundary="fdj2RfSjLxBAspz7"
Content-Disposition: inline


--fdj2RfSjLxBAspz7
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Aug 19, 2009 at 02:39:57PM -0500, Dan Williams wrote:
> On Wed, 2009-08-19 at 20:56 +0200, Beno=EEt Vaillant wrote:
> > /*
> > Just a bit of context information:
> > I'm using an MID (quite close to an Aigo, although bios differs,
> > probably some hardware too, yet I've not checked much on that). I'm
> > trying to use my Marvell card to get wifi access on a debian
> > installation. The other OS installed (midinux) successfully gets a
> > connection using the 8686_v9 mobilin driver, so I'd not go for any
> > hardware issue. This driver failing to compile 'out of the box' on
> > fresh kernels, I thought getting the libertas module working would be
> > a better way to get through.
> > */
> > <snip>
>=20
> Just for context, what SDIO controller are you using on this platform?

Sure, i can provide that!

lspci claims i's an:
00:e1.0 SD Host controler: Intel Corporation System Controller Hub (SCH Pou=
lsbo) SDIO Controller #1 (rev 06)
00:e1.1 SD Host controler: Intel Corporation System Controller Hub (SCH Pou=
lsbo) SDIO Controller #2 (rev 06)

Complete `lspci -vvv` is attached.

Could this lead to anything already known which i have might missed?

Thanks,

--=20
Beno=EEt


--fdj2RfSjLxBAspz7
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: attachment; filename="lspci-vvv.txt"

00:00.0 Host bridge: Intel Corporation Device 8101 (rev 06)
	Subsystem: COMPAL Electronics Inc Device 002e
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0

00:02.0 VGA compatible controller: Intel Corporation Device 8109 (rev 06) (prog-if 00 [VGA controller])
	Subsystem: COMPAL Electronics Inc Device 002e
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 7
	Region 0: Memory at c8080000 (32-bit, non-prefetchable) [size=512K]
	Region 1: I/O ports at 1800 [size=8]
	Region 2: Memory at d0000000 (32-bit, non-prefetchable) [size=128M]
	Region 3: Memory at c8000000 (32-bit, non-prefetchable) [size=128K]
	Expansion ROM at <unassigned> [disabled]
	Capabilities: [d0] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [b0] Vendor Specific Information <?>
	Capabilities: [90] MSI: Enable- Count=1/1 Maskable- 64bit-
		Address: 00000000  Data: 0000

00:1a.0 USB Controller: Intel Corporation System Controller Hub (SCH Poulsbo) USB Client Controller (rev 06) (prog-if 80 [Unspecified])
	Subsystem: COMPAL Electronics Inc Device 002e
	Control: I/O- Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 255
	Region 0: Memory at c8020000 (32-bit, non-prefetchable) [disabled] [size=4K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-

00:1b.0 Audio device: Intel Corporation System Controller Hub (SCH Poulsbo) HD Audio Controller (rev 06)
	Subsystem: COMPAL Electronics Inc Device 002e
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 255
	Region 0: Memory at c8024000 (64-bit, non-prefetchable) [size=16K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold-)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [70] Express (v1) Root Complex Integrated Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- RBE- FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
		LnkCap:	Port #0, Speed unknown, Width x0, ASPM unknown, Latency L0 <64ns, L1 <1us
			ClockPM- Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM L0s Enabled; Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed unknown, Width x0, TrErr- Train- SlotClk- DLActive- BWMgmt- ABWMgmt-
	Capabilities: [100] Virtual Channel <?>
	Capabilities: [130] Root Complex Link <?>

00:1d.0 USB Controller: Intel Corporation System Controller Hub (SCH Poulsbo) USB UHCI #1 (rev 06) (prog-if 00 [UHCI])
	Subsystem: COMPAL Electronics Inc Device 002e
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 23
	Region 4: I/O ports at 1820 [size=32]
	Kernel driver in use: uhci_hcd

00:1d.1 USB Controller: Intel Corporation System Controller Hub (SCH Poulsbo) USB UHCI #2 (rev 06) (prog-if 00 [UHCI])
	Subsystem: COMPAL Electronics Inc Device 002e
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin B routed to IRQ 19
	Region 4: I/O ports at 1840 [size=32]
	Kernel driver in use: uhci_hcd

00:1d.2 USB Controller: Intel Corporation System Controller Hub (SCH Poulsbo) USB UHCI #3 (rev 06) (prog-if 00 [UHCI])
	Subsystem: COMPAL Electronics Inc Device 002e
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin C routed to IRQ 18
	Region 4: I/O ports at 1860 [size=32]
	Kernel driver in use: uhci_hcd

00:1d.7 USB Controller: Intel Corporation System Controller Hub (SCH Poulsbo) USB EHCI #1 (rev 06) (prog-if 20 [EHCI])
	Subsystem: COMPAL Electronics Inc Device 002e
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin D routed to IRQ 21
	Region 0: Memory at c8021000 (32-bit, non-prefetchable) [size=1K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Debug port: BAR=1 offset=00a0
	Kernel driver in use: ehci_hcd

00:1e.0 SD Host controller: Intel Corporation System Controller Hub (SCH Poulsbo) SDIO Controller #1 (rev 06) (prog-if 01)
	Subsystem: COMPAL Electronics Inc Device 002e
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 22
	Region 0: Memory at c8021400 (32-bit, non-prefetchable) [size=256]
	Kernel driver in use: sdhci-pci

00:1e.1 SD Host controller: Intel Corporation System Controller Hub (SCH Poulsbo) SDIO Controller #2 (rev 06) (prog-if 01)
	Subsystem: COMPAL Electronics Inc Device 002e
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin B routed to IRQ 20
	Region 0: Memory at c8021800 (32-bit, non-prefetchable) [size=256]
	Kernel driver in use: sdhci-pci

00:1f.0 ISA bridge: Intel Corporation System Controller Hub (SCH Poulsbo) LPC Bridge (rev 06)
	Subsystem: COMPAL Electronics Inc Device 002e
	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Kernel driver in use: isch_smbus

00:1f.1 IDE interface: Intel Corporation System Controller Hub (SCH Poulsbo) IDE Controller (rev 06) (prog-if 80 [Master])
	Subsystem: COMPAL Electronics Inc Device 002e
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Region 0: [virtual] Memory at 000001f0 (32-bit, non-prefetchable) [size=8]
	Region 1: [virtual] Memory at 000003f0 (type 3, non-prefetchable) [size=1]
	Region 2: [virtual] Memory at 00000170 (32-bit, non-prefetchable) [size=8]
	Region 3: [virtual] Memory at 00000370 (type 3, non-prefetchable) [size=1]
	Region 4: I/O ports at 1810 [size=16]
	Kernel driver in use: pata_sch


--fdj2RfSjLxBAspz7--

--0eh6TmSyL6TZE2Uz
Content-Type: application/pgp-signature; name="~/.gnupg/public_key.txt"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkqNtNMACgkQqNn0jQsEC2ZfUQCgjOLzjeGydL89K96oWrwavT4k
lf8An2GKjHjxbFSnhXwTOeLQ1mVV5BGs
=cL2a
-----END PGP SIGNATURE-----

--0eh6TmSyL6TZE2Uz--
