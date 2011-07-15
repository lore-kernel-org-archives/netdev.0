From: wwguy <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: iwlagn: Random "Time out reading EEPROM".
Date: Fri, 15 Jul 2011 07:28:31 -0700
Message-ID: <1310740111.13897.13.camel@wwguy-ubuntu>
References: <4DEA2FC1.2030104@gmail.com>
	 <1307284276.6918.17.camel@wwguy-ubuntu>  <4E1FF8B8.9020005@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "dhalperi-GmWTxIRN22iJaUV4rX00uodd74u8MsAO@public.gmane.org" <dhalperi-GmWTxIRN22iJaUV4rX00uodd74u8MsAO@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Nicolas de =?ISO-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4E1FF8B8.9020005-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-07-15 at 01:22 -0700, Nicolas de Peslo=C3=BCan wrote:
> Le 05/06/2011 16:31, wwguy a =C3=A9crit :
> > On Sat, 2011-06-04 at 06:14 -0700, Nicolas de Peslo=C3=BCan wrote:
> >> Hi,
> >>
> >>   From time to time, my Intel Wifi adapter fail on cold boot, with=
 the following in dmesg:
> >>
> >> [    7.442634] iwlagn: Intel(R) Wireless WiFi Link AGN driver for =
Linux, 1.3.27ks
> >> [    7.442636] iwlagn: Copyright(c) 2003-2009 Intel Corporation
> >> [    7.442701] iwlagn 0000:05:00.0: PCI INT A ->  GSI 18 (level, l=
ow) ->  IRQ 18
> >> [    7.442708] iwlagn 0000:05:00.0: setting latency timer to 64
> >> [    7.442788] iwlagn 0000:05:00.0: Detected Intel Wireless WiFi L=
ink 5100AGN REV=3D0x54
> >> [    7.455547] iwlagn 0000:05:00.0: Time out reading EEPROM[0]
> >> [    7.455611] iwlagn 0000:05:00.0: Unable to init EEPROM
> >> [    7.455678] iwlagn 0000:05:00.0: PCI INT A disabled
> >> [    7.455685] iwlagn: probe of 0000:05:00.0 failed with error -11=
0
> >>
> >> After "modprobe -r iwlagn ; modprobe iwlagn" or after a reboot, ev=
erything work fine:
> >>
> >> [  346.332166] iwlagn: Intel(R) Wireless WiFi Link AGN driver for =
Linux, 1.3.27ks
> >> [  346.332169] iwlagn: Copyright(c) 2003-2009 Intel Corporation
> >> [  346.332225] iwlagn 0000:05:00.0: PCI INT A ->  GSI 18 (level, l=
ow) ->  IRQ 18
> >> [  346.332234] iwlagn 0000:05:00.0: setting latency timer to 64
> >> [  346.332277] iwlagn 0000:05:00.0: Detected Intel Wireless WiFi L=
ink 5100AGN REV=3D0x54
> >> [  346.365739] iwlagn 0000:05:00.0: Tunable channels: 13 802.11bg,=
 24 802.11a channels
> >> [  346.365787]   alloc irq_desc for 33 on node -1
> >> [  346.365788]   alloc kstat_irqs on node -1
> >> [  346.365804] iwlagn 0000:05:00.0: irq 33 for MSI/MSI-X
> >> [  346.449989] phy0: Selected rate control algorithm 'iwl-agn-rs'
> >>
> >> This happens using 2.6.32-5 from Debian. I didn't had the opportun=
ity to reproduce it using recent
> >> kernel, but it occurs too rarely to conclude anything.
> >>
> >> I had a look at the git log, without finding something that seems =
related to this problem. Does this
> >> ring a bell for someone?
> >>
> >> 	Nicolas.
> >>
> >> 05:00.0 Network controller: Intel Corporation WiFi Link 5100
> >>           Subsystem: Intel Corporation WiFi Link 5100 AGN
> >>           Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASno=
op- ParErr- Stepping- SERR-
> >> FastB2B- DisINTx-
> >>           Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast>=
TAbort-<TAbort-<MAbort->SERR-
> >> <PERR- INTx-
> >>           Latency: 0, Cache Line Size: 64 bytes
> >>           Interrupt: pin A routed to IRQ 33
> >>           Region 0: Memory at d6d00000 (64-bit, non-prefetchable) =
[size=3D8K]
> >>           Capabilities: [c8] Power Management version 3
> >>                   Flags: PMEClk- DSI+ D1- D2- AuxCurrent=3D0mA PME=
(D0+,D1-,D2-,D3hot+,D3cold+)
> >>                   Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScal=
e=3D0 PME-
> >>           Capabilities: [d0] MSI: Enable+ Count=3D1/1 Maskable- 64=
bit+
> >>                   Address: 00000000fee0300c  Data: 41c9
> >>           Capabilities: [e0] Express (v1) Endpoint, MSI 00
> >>                   DevCap: MaxPayload 128 bytes, PhantFunc 0, Laten=
cy L0s<512ns, L1 unlimited
> >>                           ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ F=
LReset+
> >>                   DevCtl: Report errors: Correctable- Non-Fatal- F=
atal- Unsupported-
> >>                           RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSn=
oop+ FLReset-
> >>                           MaxPayload 128 bytes, MaxReadReq 128 byt=
es
> >>                   DevSta: CorrErr+ UncorrErr- FatalErr- UnsuppReq+=
 AuxPwr+ TransPend-
> >>                   LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L=
0s L1, Latency L0<128ns, L1<32us
> >>                           ClockPM+ Surprise- LLActRep- BwNot-
> >>                   LnkCtl: ASPM L1 Enabled; RCB 64 bytes Disabled- =
Retrain- CommClk+
> >>                           ExtSynch- ClockPM- AutWidDis- BWInt- Aut=
BWInt-
> >>                   LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- S=
lotClk+ DLActive- BWMgmt- ABWMgmt-
> >>           Capabilities: [100 v1] Advanced Error Reporting
> >>                   UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt-=
 UnxCmplt- RxOF- MalfTLP- ECRC-
> >> UnsupReq- ACSViol-
> >>                   UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt-=
 UnxCmplt- RxOF- MalfTLP- ECRC-
> >> UnsupReq- ACSViol-
> >>                   UESvrt: DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt-=
 UnxCmplt- RxOF+ MalfTLP+ ECRC-
> >> UnsupReq- ACSViol-
> >>                   CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeou=
t- NonFatalErr+
> >>                   CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeou=
t- NonFatalErr+
> >>                   AERCap: First Error Pointer: 00, GenCap- CGenEn-=
 ChkCap- ChkEn-
> >>           Capabilities: [140 v1] Device Serial Number 00-22-fb-ff-=
ff-28-46-c8
> >>           Kernel driver in use: iwlagn
> >>
> >
> > no sure, you are the ONLY one report this issue, since the device w=
orks
> > after you reload the module, the HW/SW is ok. maybe the timing/sequ=
ence
> > have problem on the kernel you are using on your system. The bus is=
 not
> > ready when you boot the system and access the EEPROM.
> >
> > What model of the laptop you have? could you try to upgrade to newe=
r
> > kernel?
>=20
> This problem also happens using 2.6.39-2-amd64 from Debian.
>=20
> [    8.507426] iwlagn: Intel(R) Wireless WiFi Link AGN driver for Lin=
ux, in-tree:
> [    8.507429] iwlagn: Copyright(c) 2003-2010 Intel Corporation
> [    8.507521] iwlagn 0000:05:00.0: PCI INT A -> GSI 18 (level, low) =
-> IRQ 18
> [    8.507529] iwlagn 0000:05:00.0: setting latency timer to 64
> [    8.507556] iwlagn 0000:05:00.0: Detected Intel(R) WiFi Link 5100 =
AGN, REV=3D0x54
> [    8.516687] iwlagn 0000:05:00.0: Time out reading EEPROM[2]
> [    8.516724] iwlagn 0000:05:00.0: Unable to init EEPROM
> [    8.516739] iwlagn 0000:05:00.0: PCI INT A disabled
> [    8.516745] iwlagn: probe of 0000:05:00.0 failed with error -110
>=20
> modprobe -r iwlagn ; modprobe iwlagn
>=20
> [  208.948664] iwlagn: Intel(R) Wireless WiFi Link AGN driver for Lin=
ux, in-tree:
> [  208.948666] iwlagn: Copyright(c) 2003-2010 Intel Corporation
> [  208.948743] iwlagn 0000:05:00.0: PCI INT A -> GSI 18 (level, low) =
-> IRQ 18
> [  208.948753] iwlagn 0000:05:00.0: setting latency timer to 64
> [  208.948817] iwlagn 0000:05:00.0: Detected Intel(R) WiFi Link 5100 =
AGN, REV=3D0x54
> [  208.969659] iwlagn 0000:05:00.0: device EEPROM VER=3D0x11f, CALIB=3D=
0x4
> [  208.969661] iwlagn 0000:05:00.0: Device SKU: 0Xb
> [  208.969701] iwlagn 0000:05:00.0: Tunable channels: 13 802.11bg, 24=
 802.11a channels
> [  208.969766] iwlagn 0000:05:00.0: irq 50 for MSI/MSI-X
> [  209.048366] iwlagn 0000:05:00.0: loaded firmware version 8.83.5.1 =
build 33692
>=20
> Because it happens not very often, I still didn't had the opportunity=
 to reproduce it with up to=20
> date kernel.
>=20
> The laptop is a two years old Sony Vaio VGN-AW21M.
>=20
the error indicate fail to read data from EEPROM, your 2nd report is
even more strange, the number at the end the error message indicate the
index of DWORD driver trying to read from EEPROM.=20

"Time out reading EEPROM[2]" telling me the first 2 DWORD is reading ok
but not the 3rd read.

How many PCI-E slots you have in your system, could it possible for you
to switch to another PCI-E slot, or pull out and re-insert the NIC.

Also, it is possible to put the NIC into different system and see if yo=
u
are seeing the similar problem?

Thanks
Wey


--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
