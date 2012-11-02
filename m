From: Jeff Kirsher <tarbal@gmail.com>
Subject: Re: [3.5/6.x][e1000e] - Regression - Unable to receive packets if
 MTU == 1500
Date: Fri, 02 Nov 2012 01:40:38 -0700
Message-ID: <50938706.1020900@gmail.com>
References: <1570009.hYb0226lHg@segfault.sh0n.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="------------enig0665B6AACF157124D132EFEC"
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Shawn Starr <shawn.starr@rogers.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:44014 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754099Ab2KBIkk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Nov 2012 04:40:40 -0400
In-Reply-To: <1570009.hYb0226lHg@segfault.sh0n.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig0665B6AACF157124D132EFEC
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/01/2012 10:58 AM, Shawn Starr wrote:
> Hello network driver folks,
>
> I recently decided to reinstall my Lenovo W500 laptop and found I wasn'=
t able=20
> to get DHCP leases, I wasn't able to install over PXE (when getting the=
 IP a=20
> second time within the OS)
>
> Fedora is currently using kernel-3.6.2-2.fc18.x86_64 (Pre-beta)
>
> The only difference I noticed was in my old install of Fedora, I had ad=
ded=20
> MTU=3D9000 to the interface config while using a 3.5 kernel, not knowin=
g 3.6.x=20
> seems to break things.
>
> My Cisco DPC3825 Switch/Cable modem has an MTU setting but this is from=
 Cable=20
> provider <-> WAN interface only. I tried changing to 1500 but by defaul=
t it=20
> uses this anyway.
>
> I had noticed tx unit hang errors sometimes, but not when MTU is above =
1500.
>
> PCI info:
>
> 00:19.0 Ethernet controller: Intel Corporation 82567LM Gigabit Network =

> Connection (rev 03)
>         Subsystem: Lenovo Device 20ee
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- Par=
Err-=20
> Stepping- SERR+ FastB2B- DisINTx+
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
-=20
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0
>         Interrupt: pin A routed to IRQ 46
>         Region 0: Memory at fc000000 (32-bit, non-prefetchable) [size=3D=
128K]
>         Region 1: Memory at fc025000 (32-bit, non-prefetchable) [size=3D=
4K]
>         Region 2: I/O ports at 1840 [size=3D32]
>         Capabilities: [c8] Power Management version 2
>                 Flags: PMEClk- DSI+ D1- D2- AuxCurrent=3D0mA=20
> PME(D0+,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D1 P=
ME-
>         Capabilities: [d0] MSI: Enable+ Count=3D1/1 Maskable- 64bit+
>                 Address: 00000000fee0100c  Data: 41a2
>         Capabilities: [e0] PCI Advanced Features
>                 AFCap: TP+ FLR+
>                 AFCtrl: FLR-
>                 AFStatus: TP-
>         Kernel driver in use: e1000e
>
> e1000e conversation log:
>
> [   12.653816] e1000e: Intel(R) PRO/1000 Network Driver - 2.0.0-k
> [   12.653819] e1000e: Copyright(c) 1999 - 2012 Intel Corporation.
> [   12.653855] e1000e 0000:00:19.0: setting latency timer to 64
> [   12.653938] e1000e 0000:00:19.0: Interrupt Throttling Rate (ints/sec=
) set=20
> to dynamic conservative mode
> [   12.653980] e1000e 0000:00:19.0: irq 46 for MSI/MSI-X
> [   12.844121] e1000e 0000:00:19.0: eth0: (PCI Express:2.5GT/s:Width x1=
)=20
> 00:22:68:0c:96:e3
> [   12.844124] e1000e 0000:00:19.0: eth0: Intel(R) PRO/1000 Network Con=
nection
> [   12.844150] e1000e 0000:00:19.0: eth0: MAC: 7, PHY: 8, PBA No: 1008F=
F-0FF
> [   17.459570] e1000e 0000:00:19.0: eth0: changing MTU from 1500 to 900=
0
> [   17.459577] e1000e 0000:00:19.0: Interrupt Throttle Rate turned off
> [   17.948121] e1000e 0000:00:19.0: irq 46 for MSI/MSI-X
> [   18.049164] e1000e 0000:00:19.0: irq 46 for MSI/MSI-X
> [   20.442936] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow =

> Control: Rx/Tx
>
> When I set MTU =3D 1500 (2000 works), it will stop receiving packets, i=
t also=20
> disables Interrupt Throttling when MTU is set higher.
>
> After testing reasons why it wasn't get a DHCP lease, I decided to bump=
 the=20
> MTU to 9000 for Jumbo Frames and as soon as I did this, I was able to g=
et a=20
> lease and the network functioned resumes receiving packets.
>
> Can anyone else report regressions or might know whats going on?
>
> Thanks,
> Shawn.
Adding e1000-devel mailing list


--------------enig0665B6AACF157124D132EFEC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://www.enigmail.net/

iQIcBAEBCgAGBQJQk4cGAAoJEOVv75VaS+3OQ7kQAIGtEW/MryEDtdqyIedwVXcF
zqPKfZUFR/1zOI2bmzWvbnav+pSsR0Ks693oC+/SRymCzkg7J7+lztUhe54ZkNNj
pPIuAkIdAjy7EKBimi5mfZ5XXanahZzYuFhg/KQn7+zQzHAWMU7VKQK+/xZvPKmW
rReq2uT4Jmj6V6xfZhyAFBbHPPIDMJtsn29P/2IasH0/YAXAbIx9VOq5y6FKCEUp
widjzolouLbH5RNsKWNZBesk3gygLu1K52X3FWRZqNDxIk0hQ1a8mH3yUjpT2NrQ
BVJy8xkinwfkGIrqex9VJvGcITcuP0weLwh5YH+OGuzSZdJVSeUv4oVtAvhdZzb+
QIIawAPUXKS6DmaUZkWMecPIxd2Z2AFRoRDCGbKarBQW9+tdq6lM+uOsJw4GAXma
b9FZzd4Km3gJeo9VkhpOLroT8xcc5RsbJ0R7xkiYCoriwliRvAKeo6PnYJmKeWWt
ZPZc8Oh/kV1JW7lTVOezvAFAKe0CrJh4qBaRIwUb0BJHG/qoudoaKrXvQAJP8T/b
ru+KgcTvIoWoZJE2+AtUfqYx3SU8MrH4UqXRQJLc2fdimPw41dw445FwYso8w+Le
TEyYKLsNafe506IQO6EbqVb9dwoQws7vREA8u3f12Rj1EuHp4Nn2Kdkl+nS5X8cp
dMJOGCRcqqAfYuRm9/Hu
=/bCM
-----END PGP SIGNATURE-----

--------------enig0665B6AACF157124D132EFEC--
