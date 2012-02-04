From: Paul Menzel <pm.debian@googlemail.com>
Subject: Re: Bug#656331: RTL8168b/8111b with ASUS M2A-VM (SB600): Network
 device stays down after resume
Date: Sat, 04 Feb 2012 20:26:03 +0100
Message-ID: <1328383563.20142.23.camel@mattotaupa>
References: <1326896138.29125.86.camel@mattotaupa>
	 <1326899011.3271.3.camel@deadeye> <1326900763.29125.117.camel@mattotaupa>
	 <1326901834.3271.8.camel@deadeye>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-+dbAH108zdV1q6C1C+BK"
Cc: 656331@bugs.debian.org, netdev@vger.kernel.org
To: nic_swsd@realtek.com, Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:56001 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754386Ab2BDT0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2012 14:26:08 -0500
Received: by bkcjm19 with SMTP id jm19so3847211bkc.19
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2012 11:26:07 -0800 (PST)
In-Reply-To: <1326901834.3271.8.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-+dbAH108zdV1q6C1C+BK
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

found 656331 3.2.2-1
quit


Dear Linux folks,


Am Mittwoch, den 18.01.2012, 15:50 +0000 schrieb Ben Hutchings:
> On Wed, 2012-01-18 at 16:32 +0100, Paul Menzel wrote:
> > Am Mittwoch, den 18.01.2012, 15:03 +0000 schrieb Ben Hutchings:
> > > On Wed, 2012-01-18 at 15:15 +0100, Paul Menzel wrote:
> > > > Package: linux-2.6
> > > > Version: 3.1.8-2
> > > > Severity: normal
> >=20
> > > > suspending and resuming a lot, it happens once to me, that the netw=
ork
> > > > device did not come back correctly.

I experienced this problem (only) three times until now. If I remember
correctly the last time with 3.2.1. I still do not know how to reproduce
this.

The work around is to unplug and replug the network cable or to unload
the module and load it again.

> > > [...]
> > >=20
> > > Some of the RTL81xx gigabit Ethernet controllers need a firmware patc=
h
> > > to be reliable.  I can't tell whether you have one of these.  Are the=
re
> > > any kernel log messages about requesting a firmware file for the NIC?
> > > If so, does installing firmware-realtek fix the problem?
> >=20
> > There are no Linux messages requesting the firmware.
>=20
> OK.
>=20
> > And not being able
> > to trigger I probably just have to wait that it happens again. Can I
> > increase some log level to capture more information next time? Or since
> > this could be a firmware bug Linux cannot do anything about this?
>=20
> No, it's probably something that can be fixed in the driver.

That sounds promising. It would be great if this could be fixed. Please
tell me how I can get you better debugging information next time this
happens.

> > $ dmesg | grep -i firmware
> > $ dmesg | grep 8169
> > [    1.109369] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
> > [    1.109417] r8169 0000:02:00.0: PCI INT A -> GSI 19 (level, low) -> =
IRQ 19
> > [    1.109452] r8169 0000:02:00.0: setting latency timer to 64
> > [    1.109511] r8169 0000:02:00.0: irq 41 for MSI/MSI-X
> > [    1.110094] r8169 0000:02:00.0: eth0: RTL8168b/8111b at 0xffffc90000=
364000, 00:1e:8c:aa:1d:b5, XID 18000000 IRQ 41
> [...]
>=20
> Right, this variant doesn't need a firmware patch.
>=20
> Please can you re-send your bug report to:

[=E2=80=A6]

> Be sure to include the log messages from your second mail.

Please find the messages from the Linux kernel ring buffer (`dmesg`)
attached at the end.


Thanks,

Paul


[1] http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=3D656331


$ dmesg | grep -i firmware
$ dmesg | grep 8169
[    1.109369] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    1.109417] r8169 0000:02:00.0: PCI INT A -> GSI 19 (level, low) -> IRQ =
19
[    1.109452] r8169 0000:02:00.0: setting latency timer to 64
[    1.109511] r8169 0000:02:00.0: irq 41 for MSI/MSI-X
[    1.110094] r8169 0000:02:00.0: eth0: RTL8168b/8111b at 0xffffc900003640=
00, 00:1e:8c:aa:1d:b5, XID 18000000 IRQ 41
[  299.062777] r8169 0000:02:00.0: eth0: link down
[  300.770805] r8169 0000:02:00.0: eth0: link up
[ 3287.250629] r8169 0000:02:00.0: PME# enabled
[ 3287.397826] r8169 0000:02:00.0: restoring config space at offset 0xf (wa=
s 0x100, writing 0x10a)
[ 3287.397841] r8169 0000:02:00.0: restoring config space at offset 0x6 (wa=
s 0x4, writing 0xfdfff004)
[ 3287.397848] r8169 0000:02:00.0: restoring config space at offset 0x4 (wa=
s 0x1, writing 0xdc01)
[ 3287.397853] r8169 0000:02:00.0: restoring config space at offset 0x3 (wa=
s 0x0, writing 0x8)
[ 3287.397860] r8169 0000:02:00.0: restoring config space at offset 0x1 (wa=
s 0x100000, writing 0x100407)
[ 3287.398443] r8169 0000:02:00.0: PME# disabled
[ 3314.429403] r8169 0000:02:00.0: eth0: link down
[ 3314.429432] r8169 0000:02:00.0: eth0: link down
[ 3316.043306] r8169 0000:02:00.0: eth0: link up
[ 4821.512812] r8169 0000:02:00.0: PME# enabled
[ 4821.661948] r8169 0000:02:00.0: restoring config space at offset 0xf (wa=
s 0x100, writing 0x10a)
[ 4821.661963] r8169 0000:02:00.0: restoring config space at offset 0x6 (wa=
s 0x4, writing 0xfdfff004)
[ 4821.661969] r8169 0000:02:00.0: restoring config space at offset 0x4 (wa=
s 0x1, writing 0xdc01)
[ 4821.661975] r8169 0000:02:00.0: restoring config space at offset 0x3 (wa=
s 0x0, writing 0x8)
[ 4821.661981] r8169 0000:02:00.0: restoring config space at offset 0x1 (wa=
s 0x100000, writing 0x100407)
[ 4821.662532] r8169 0000:02:00.0: PME# disabled
[ 4839.563375] r8169 0000:02:00.0: eth0: link down
[ 4839.563398] r8169 0000:02:00.0: eth0: link down
[ 4841.198305] r8169 0000:02:00.0: eth0: link up
[ 7732.802716] r8169 0000:02:00.0: PME# enabled
[ 7732.910146] r8169 0000:02:00.0: restoring config space at offset 0xf (wa=
s 0x100, writing 0x10a)
[ 7732.910161] r8169 0000:02:00.0: restoring config space at offset 0x6 (wa=
s 0x4, writing 0xfdfff004)
[ 7732.910168] r8169 0000:02:00.0: restoring config space at offset 0x4 (wa=
s 0x1, writing 0xdc01)
[ 7732.910173] r8169 0000:02:00.0: restoring config space at offset 0x3 (wa=
s 0x0, writing 0x8)
[ 7732.910180] r8169 0000:02:00.0: restoring config space at offset 0x1 (wa=
s 0x100000, writing 0x100407)
[ 7732.910733] r8169 0000:02:00.0: PME# disabled
[ 7761.865970] r8169 0000:02:00.0: eth0: link down
[ 7761.865984] r8169 0000:02:00.0: eth0: link down
[ 7763.542738] r8169 0000:02:00.0: eth0: link up
[15484.178593] r8169 0000:02:00.0: PME# enabled
[15484.346084] r8169 0000:02:00.0: restoring config space at offset 0xf (wa=
s 0x100, writing 0x10a)
[15484.346099] r8169 0000:02:00.0: restoring config space at offset 0x6 (wa=
s 0x4, writing 0xfdfff004)
[15484.346106] r8169 0000:02:00.0: restoring config space at offset 0x4 (wa=
s 0x1, writing 0xdc01)
[15484.346111] r8169 0000:02:00.0: restoring config space at offset 0x3 (wa=
s 0x0, writing 0x8)
[15484.346118] r8169 0000:02:00.0: restoring config space at offset 0x1 (wa=
s 0x100000, writing 0x100407)
[15484.347428] r8169 0000:02:00.0: PME# disabled
[15510.394744] r8169 0000:02:00.0: eth0: link down
[15510.394763] r8169 0000:02:00.0: eth0: link down
[15512.071499] r8169 0000:02:00.0: eth0: link up
[18259.334467] r8169 0000:02:00.0: PME# enabled
[18259.501850] r8169 0000:02:00.0: restoring config space at offset 0xf (wa=
s 0x100, writing 0x10a)
[18259.501865] r8169 0000:02:00.0: restoring config space at offset 0x6 (wa=
s 0x4, writing 0xfdfff004)
[18259.501872] r8169 0000:02:00.0: restoring config space at offset 0x4 (wa=
s 0x1, writing 0xdc01)
[18259.501877] r8169 0000:02:00.0: restoring config space at offset 0x3 (wa=
s 0x0, writing 0x8)
[18259.501884] r8169 0000:02:00.0: restoring config space at offset 0x1 (wa=
s 0x100000, writing 0x100407)
[18259.502438] r8169 0000:02:00.0: PME# disabled
[18278.302713] r8169 0000:02:00.0: eth0: link down
[18278.302745] r8169 0000:02:00.0: eth0: link down
[18280.011036] r8169 0000:02:00.0: eth0: link up
[25756.542579] r8169 0000:02:00.0: PME# enabled
[25756.603094] r8169 0000:02:00.0: restoring config space at offset 0xf (wa=
s 0x100, writing 0x10a)
[25756.603109] r8169 0000:02:00.0: restoring config space at offset 0x6 (wa=
s 0x4, writing 0xfdfff004)
[25756.603116] r8169 0000:02:00.0: restoring config space at offset 0x4 (wa=
s 0x1, writing 0xdc01)
[25756.603121] r8169 0000:02:00.0: restoring config space at offset 0x3 (wa=
s 0x0, writing 0x8)
[25756.603128] r8169 0000:02:00.0: restoring config space at offset 0x1 (wa=
s 0x100000, writing 0x100407)
[25756.603748] r8169 0000:02:00.0: PME# disabled
[25777.623022] r8169 0000:02:00.0: eth0: link down
[25777.623051] r8169 0000:02:00.0: eth0: link down
[25779.226514] r8169 0000:02:00.0: eth0: link up
[31478.251100] r8169 0000:02:00.0: PME# enabled
[31478.421917] r8169 0000:02:00.0: restoring config space at offset 0xf (wa=
s 0x100, writing 0x10a)
[31478.421933] r8169 0000:02:00.0: restoring config space at offset 0x6 (wa=
s 0x4, writing 0xfdfff004)
[31478.421939] r8169 0000:02:00.0: restoring config space at offset 0x4 (wa=
s 0x1, writing 0xdc01)
[31478.421945] r8169 0000:02:00.0: restoring config space at offset 0x3 (wa=
s 0x0, writing 0x8)
[31478.421952] r8169 0000:02:00.0: restoring config space at offset 0x1 (wa=
s 0x100000, writing 0x100407)
[31478.422570] r8169 0000:02:00.0: PME# disabled
[31503.383109] r8169 0000:02:00.0: eth0: link down
[31503.383136] r8169 0000:02:00.0: eth0: link down
[31505.007435] r8169 0000:02:00.0: eth0: link up
[38537.983241] r8169 0000:02:00.0: PME# enabled
[38538.137904] r8169 0000:02:00.0: restoring config space at offset 0xf (wa=
s 0x100, writing 0x10a)
[38538.137919] r8169 0000:02:00.0: restoring config space at offset 0x6 (wa=
s 0x4, writing 0xfdfff004)
[38538.137926] r8169 0000:02:00.0: restoring config space at offset 0x4 (wa=
s 0x1, writing 0xdc01)
[38538.137931] r8169 0000:02:00.0: restoring config space at offset 0x3 (wa=
s 0x0, writing 0x8)
[38538.137938] r8169 0000:02:00.0: restoring config space at offset 0x1 (wa=
s 0x100000, writing 0x100407)
[38538.138558] r8169 0000:02:00.0: PME# disabled
[38561.350684] r8169 0000:02:00.0: eth0: link down
[38561.350695] r8169 0000:02:00.0: eth0: link down
[38563.006502] r8169 0000:02:00.0: eth0: link up
[55418.966878] r8169 0000:02:00.0: PME# enabled
[55419.198252] r8169 0000:02:00.0: restoring config space at offset 0xf (wa=
s 0x100, writing 0x10a)
[55419.198269] r8169 0000:02:00.0: restoring config space at offset 0x6 (wa=
s 0x4, writing 0xfdfff004)
[55419.198276] r8169 0000:02:00.0: restoring config space at offset 0x4 (wa=
s 0x1, writing 0xdc01)
[55419.198281] r8169 0000:02:00.0: restoring config space at offset 0x3 (wa=
s 0x0, writing 0x8)
[55419.198288] r8169 0000:02:00.0: restoring config space at offset 0x1 (wa=
s 0x100000, writing 0x100407)
[55419.199056] r8169 0000:02:00.0: PME# disabled
[55463.662649] r8169 0000:02:00.0: eth0: link down
[55463.662669] r8169 0000:02:00.0: eth0: link down
[55579.968121] r8169 0000:02:00.0: eth0: link down
[55581.637656] r8169 0000:02:00.0: eth0: link up

# These two messages above came from the incident that I needed to replug t=
he network cable.

[69238.835220] r8169 0000:02:00.0: PME# enabled
[69239.030058] r8169 0000:02:00.0: restoring config space at offset 0xf (wa=
s 0x100, writing 0x10a)
[69239.030073] r8169 0000:02:00.0: restoring config space at offset 0x6 (wa=
s 0x4, writing 0xfdfff004)
[69239.030079] r8169 0000:02:00.0: restoring config space at offset 0x4 (wa=
s 0x1, writing 0xdc01)
[69239.030085] r8169 0000:02:00.0: restoring config space at offset 0x3 (wa=
s 0x0, writing 0x8)
[69239.030091] r8169 0000:02:00.0: restoring config space at offset 0x1 (wa=
s 0x100000, writing 0x100407)
[69239.030715] r8169 0000:02:00.0: PME# disabled
[69302.909251] r8169 0000:02:00.0: eth0: link down
[69302.909270] r8169 0000:02:00.0: eth0: link down
[69304.585998] r8169 0000:02:00.0: eth0: link up
[75793.819387] r8169 0000:02:00.0: PME# enabled
[75793.965963] r8169 0000:02:00.0: restoring config space at offset 0xf (wa=
s 0x100, writing 0x10a)
[75793.965979] r8169 0000:02:00.0: restoring config space at offset 0x6 (wa=
s 0x4, writing 0xfdfff004)
[75793.965986] r8169 0000:02:00.0: restoring config space at offset 0x4 (wa=
s 0x1, writing 0xdc01)
[75793.965992] r8169 0000:02:00.0: restoring config space at offset 0x3 (wa=
s 0x0, writing 0x8)
[75793.966000] r8169 0000:02:00.0: restoring config space at offset 0x1 (wa=
s 0x100000, writing 0x100407)
[75793.966980] r8169 0000:02:00.0: PME# disabled
[75820.589236] r8169 0000:02:00.0: eth0: link down
[75820.589256] r8169 0000:02:00.0: eth0: link down
[75822.287067] r8169 0000:02:00.0: eth0: link up
[80551.485608] r8169 0000:02:00.0: PME# enabled
[80551.562098] r8169 0000:02:00.0: restoring config space at offset 0xf (wa=
s 0x100, writing 0x10a)
[80551.562114] r8169 0000:02:00.0: restoring config space at offset 0x6 (wa=
s 0x4, writing 0xfdfff004)
[80551.562122] r8169 0000:02:00.0: restoring config space at offset 0x4 (wa=
s 0x1, writing 0xdc01)
[80551.562128] r8169 0000:02:00.0: restoring config space at offset 0x3 (wa=
s 0x0, writing 0x8)
[80551.562135] r8169 0000:02:00.0: restoring config space at offset 0x1 (wa=
s 0x100000, writing 0x100407)
[80551.563000] r8169 0000:02:00.0: PME# disabled
[80575.678825] r8169 0000:02:00.0: eth0: link down
[80575.678837] r8169 0000:02:00.0: eth0: link down
[80577.292704] r8169 0000:02:00.0: eth0: link up
[81125.015611] r8169 0000:02:00.0: PME# enabled
[81125.220938] r8169 0000:02:00.0: restoring config space at offset 0xf (wa=
s 0x100, writing 0x10a)
[81125.220955] r8169 0000:02:00.0: restoring config space at offset 0x6 (wa=
s 0x4, writing 0xfdfff004)
[81125.220962] r8169 0000:02:00.0: restoring config space at offset 0x4 (wa=
s 0x1, writing 0xdc01)
[81125.220968] r8169 0000:02:00.0: restoring config space at offset 0x3 (wa=
s 0x0, writing 0x8)
[81125.220976] r8169 0000:02:00.0: restoring config space at offset 0x1 (wa=
s 0x100000, writing 0x100407)
[81125.221988] r8169 0000:02:00.0: PME# disabled
[81196.764877] r8169 0000:02:00.0: eth0: link down
[81196.764899] r8169 0000:02:00.0: eth0: link down
[81198.431155] r8169 0000:02:00.0: eth0: link up

--=-+dbAH108zdV1q6C1C+BK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAk8thksACgkQPX1aK2wOHVhvmwCfYH8DN3dBEvfgBcW7KWUCm+zC
jjQAnjj9dbEAkifdyTpAod9PT+coVZR+
=Xurb
-----END PGP SIGNATURE-----

--=-+dbAH108zdV1q6C1C+BK--
