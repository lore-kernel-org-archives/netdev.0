From: Darren Salt <linux@youmustbejoking.demon.co.uk>
Subject: RTL8136
Date: Fri, 25 Aug 2006 18:15:24 +0100
Message-ID: <4E5C083B8E%linux@youmustbejoking.demon.co.uk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="2137644856--15797261--1118761282"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from anchor-post-34.mail.demon.net ([194.217.242.92]:15115 "EHLO
	anchor-post-34.mail.demon.net") by vger.kernel.org with ESMTP
	id S1422811AbWHYSam (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 14:30:42 -0400
To: romieu@fr.zoreil.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This message is in MIME format which your mailer apparently does not support.
You either require a newer version of your software which supports MIME, or
a separate MIME decoding utility.  Alternatively, ask the sender of this
message to resend it in a different format.

--2137644856--15797261--1118761282
Content-Type: text/plain; charset=us-ascii

In case you don't yet have an lspci dump for an RTL8136, here's one for a
device which is working with the r1000 driver which is supplied with Ubuntu
dapper (though the machine in question - a Toshiba Equium A110-233 - is
actually running Debian testing.)

I _should_ be able to test your patches once I've got a locally-compiled
kernel working for it.

[M-F-T set; not subscribed.]

-- 
| Darren Salt    | linux or ds at              | nr. Ashington, | Toon
| RISC OS, Linux | youmustbejoking,demon,co,uk | Northumberland | Army
| + At least 4000 million too many people. POPULATION LEVEL IS UNSUSTAINABLE.

If no one uses it, there's a reason.

--2137644856--15797261--1118761282
Content-Type: text/plain; charset=iso-8859-1; name="lspci_rtl8136.txt"
Content-Disposition: attachment; filename="lspci_rtl8136.txt"
Content-Transfer-Encoding: quoted-printable

05:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. Unknown devi=
ce 8136 (rev 01)
	Subsystem: Toshiba America Info Systems Unknown device ff00
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Step=
ping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort=
- <MAbort- >SERR- <PERR-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 185
	Region 0: I/O ports at 4000 [size=3D256]
	Region 2: Memory at da000000 (64-bit, non-prefetchable) [size=3D4K]
	[virtual] Expansion ROM at d4000000 [disabled] [size=3D64K]
	Capabilities: [40] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D375mA PME(D0-,D1+,D2+,D3hot+,D=
3cold+)
		Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME+
	Capabilities: [48] Vital Product Data
	Capabilities: [50] Message Signalled Interrupts: 64bit+ Queue=3D0/1 Enab=
le-
		Address: 0000000000000000  Data: 0000
	Capabilities: [60] Express Endpoint IRQ 0
		Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag+
		Device: Latency L0s <1us, L1 unlimited
		Device: AtnBtn+ AtnInd+ PwrInd+
		Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
		Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
		Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
		Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s, Port 0
		Link: Latency L0s unlimited, L1 unlimited
		Link: ASPM Disabled RCB 64 bytes CommClk+ ExtSynch-
		Link: Speed 2.5Gb/s, Width x1
	Capabilities: [84] Vendor Specific Information
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [12c] Virtual Channel
	Capabilities: [148] Device Serial Number 36-81-ec-10-00-00-10-01
	Capabilities: [154] Power Budgeting


--2137644856--15797261--1118761282--
