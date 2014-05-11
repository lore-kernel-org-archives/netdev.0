From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: e1000 crash on 3.15.0-rc4
Date: Sun, 11 May 2014 13:12:12 +0100
Message-ID: <1399810332.11946.127.camel@deadeye.wl.decadent.org.uk>
References: <20140507053245.GB15783@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6976336947721230323=="
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: bo.li.liu@oracle.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20140507053245.GB15783@localhost.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============6976336947721230323==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-oRnqtAQvFS703bbize5e"


--=-oRnqtAQvFS703bbize5e
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-05-07 at 13:32 +0800, Liu Bo wrote:
> Hi,
>=20
> I'm using qemu to load kernel of 3.15.0-rc4, and with CONFIG_E1000=3Dy,
> everying is ok, but with CONFIG_E1000=3Dm, I got the following crash:
>=20
> [...]
> [    6.020409] tsc: Refined TSC clocksource calibration: 2491.912 MHz
> [    6.074925] floppy: Unknown symbol mutex_lock (err 0)
> [    6.128579] virtio_blk: Unknown symbol mutex_lock (err 0)
> [    6.141264] i2c_core: Unknown symbol mutex_lock (err 0)

Really???

> [    6.167490] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k=
8-NAPI
> [    6.168240] e1000: Copyright (c) 1999-2006 Intel Corporation.
> [    6.171078] ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 10
> [    6.190295] BUG: spinlock bad magic on CPU#3, systemd-udevd/208
[...]

I think you may have rebuilt the kernel with lockdep enabled, but
haven't also rebuilt and installed the modules with lockdep enabled.

You should enable symbol versions to catch such mistakes.

Ben.

--=20
Ben Hutchings
Sturgeon's Law: Ninety percent of everything is crap.

--=-oRnqtAQvFS703bbize5e
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUAU29pJue/yOyVhhEJAQr4YxAAnZSwn3NmkpIq3Ypy3KEKLxlAdV26lO7u
PwQppS7ruY+2fzKwt6LWhXsHIj3iB1p6H7Y8H/ieq19xoe8drnoLjLshO581xbvh
POIwnoGZeyfSDf1JQe5ix37YGx6maFn7x09QLgK2p6PFFK57KVaLoLQ7bDFkGRw6
t1OAAdpPrIHI8UvWSAxufcWPGgBuWoaRqyLYbJfWodbIqQxJ+b9nB9soA8rv44C+
u671AGqeu4ihDzG7u18iS2jATyuI73E7suwI3XmcIpHOb3Z/jTTtRFkMV2OtlGJS
ComxdjTc6qzsyOLkwaMOYhcLW1g3ST4vrZcLr+6VX905QU7jlig1sXdBXxvbYCzA
kKP4etjlWWLvCNRgGeV/xD9ii4jtjAm4//sUgX5hwZ0TOCsxZF4f2QIBKcTavJ5Z
WfUov2NnR31JL8csFHKkrPoVwKg57E0Ql+sfCXnepLF/2XONr/Gu7rZUp71zHf7h
2gN8QH1U+blKGeP/TSDTLdiZzkLzKCeXwKzP8va0cESWRflbYMeqSvuneydlumIS
f711QI66lsGREActEmjfWbVREQqCxnaHKZM+wyn1SXeANDWXPGj5cpli23NAkwIa
B719nSme0kFGNaUbBITrxGyvUE/ZFOK0ZhHgm5cK005mDjOI7Hf0+YVNrE+GMbGJ
bxNI1WLrmPQ=
=IVdu
-----END PGP SIGNATURE-----

--=-oRnqtAQvFS703bbize5e--


--===============6976336947721230323==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Is your legacy SCM system holding you back? Join Perforce May 7 to find out:
&#149; 3 signs your SCM is hindering your productivity
&#149; Requirements for releasing software faster
&#149; Expert tips and advice for migrating your SCM now
http://p.sf.net/sfu/perforce
--===============6976336947721230323==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============6976336947721230323==--
