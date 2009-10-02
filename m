From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Messages are printed on screen
Date: Fri, 02 Oct 2009 11:56:36 +0100
Message-ID: <1254480996.23350.73.camel@localhost>
References: <ha4igd$ghh$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-jaSP6F4bo52wG2bHfEBg"
Cc: netdev@vger.kernel.org
To: Markus Feldmann <feldmann_markus@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:50174 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757162AbZJBK4g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 06:56:36 -0400
In-Reply-To: <ha4igd$ghh$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-jaSP6F4bo52wG2bHfEBg
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2009-10-02 at 11:52 +0200, Markus Feldmann wrote:
> Hi All,
>=20
> i am setting up my Server, with Linux Debian lenny. Therefore i am using=20
>   Kernel 2.6.31.1.

The current kernel version for 'lenny' is 2.6.26 (with stable updates
and other fixes).

2.6.31 is known to have a large number of regressions outstanding, which
is why it is not in Debian yet.

> I configured this Kernel with <make defconfig> and=20
> <make menuconfig>. My motherboard has 5 PCI slots and 1 AGP slot. All=20
> slots are in use. All devices are mapped to the following IRQ-Line:
>=20
> Mass Storage Device (PCI Slot1)	IRQ-Line 11
> Ethernet (PCI Slot 2) 		IRQ-Line 4
> Ethernet (PCI Slot 3) 		IRQ-Line 5
> Ethernet (PCI Slot 4) 		IRQ-Line 7
> Ethernet (PCI Slot 5) 		IRQ-Line 11
> Onboard USB-Controller		IRQ-Line 5
> Onboard USB-Controller		IRQ-Line 4
> Onboard USB-Controller		IRQ-Line 11
> Onboard IDE			IRQ-Line 14
> AGP VGA				IRQ-Line 11
>=20
> As you see some of my IRQ-Lines are multiply in use, so my Server is=20
> working hard at his limit.

IRQ sharing is normal on PCs without MSI support, but to see where
that's happening you need to look at /proc/interrupts and not the BIOS
setup program or wherever you got the above information from.

This does not result in 'working hard at his limit'.

> The result is sometimes freezing of my=20
> Server, especially if there is much processing on these devices. I=20
> remember that with Kernel 2.6.18 my system didn't does freezing.

This is simply a bug, not a result of IRQ sharing or 'working hard'.

> So i am trying to reduce the amount of this processing. I still get=20
> messages about dropped network packets on my Terminal, although i set up=20
> my <rsyslog> to save this only to </var/log>. Here is my=20
> </etc/rsyslog.conf>

You forgot to paste it.

> How can i disable the output of messages (about dropped packets from my=20
> firewall) to my terminal ?

Edit the value of kernel.printk in /etc/sysctl.conf.

> How can i stabilize my IRQ-System with the kernel 2.6.31.1 ?

I would expect the standard kernel version for 'lenny' or the 2.6.30
kernel from 'sid' to be more stable.

> What debug features should i disable ?

No idea, you didn't even specify what you enabled...

Ben.

--=20
Ben Hutchings
Who are all these weirdos? - David Bowie, about L-Space IRC channel #afp

--=-jaSP6F4bo52wG2bHfEBg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUASsXcX+e/yOyVhhEJAQLsJA//dRlTEYnVdtJTrwHnSCzjix/IkPUkSZR0
2X8Rkf76ZWViSXUO6WAADTGyatE669npOfIy4s2InSv0OYXdnahX8rtKVJvuwXkq
0s33UiWfoVwGnLIZB3Vi4HSyEn6Jdw0Kmp718Ks/Zq46sUwOZTPMPkycecGhzAXz
nt6lQC/hfc7TD90mDSM4FfF+8aZ2vw5I7KrNWzhCwR9Mi0H70jO5sRKVwHFB8tyG
N3Hj57VbETQL/Bh5U2Q40eZ+Gge164PMHN1sKmVf4LwWcpf3bUImzxlxh/tyebXd
fSEbi+h4cz9RydkaX+9PZ38EqFrYN06VGAyOcgP6Q/ifivR2HJnPof0WyTSYDDkf
jv6Bz2tqrc3zSmpIdHx17NFY94hrsbBCFEQQvAIuM860WSUZJ7VtiO5u32am5NgG
dknhpPeq98PaILFp1boEqMBl/GzR8EznZHVN9Q9gjMexHu92pKZE4Vhs7AChcMLI
ouljgOOXD4teYPhlSaL5vUq51Mo4aL1l0eo8S+bhl2iQPwVmTuEhjb+P+cP8om7M
wFrUQV/x19tldf8Erl1zeGr4jW92T108J3jU84lYNjnhio4deoL4aqD7FrIwcmv2
yIeLURwVlpQscTDoIcXoYVvFqT/9tAKQe20OjGUY3qY2S39SjPtilVWMAOPBEEtU
9/9H79KH8Rk=
=Et9W
-----END PGP SIGNATURE-----

--=-jaSP6F4bo52wG2bHfEBg--
