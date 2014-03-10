From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: pppd service crash in linux-3.13.6
Date: Mon, 10 Mar 2014 19:54:01 +0000
Message-ID: <1394481241.23624.10.camel@deadeye.wl.decadent.org.uk>
References: <531A37FF.4000509@totakura.in> <531DEEA6.4090808@totakura.in>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-mu+P6VoeF++zp47Ncl5n"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Sree Harsha Totakura <sreeharsha@totakura.in>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <531DEEA6.4090808@totakura.in>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-mu+P6VoeF++zp47Ncl5n
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-03-10 at 17:56 +0100, Sree Harsha Totakura wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
>=20
> Hi,
>=20
> Using linux-3.13.6, I am observing the following output from the pppd
> kernel thread.  This happens when I try to suspend my computer and it
> *stops* the computer from suspending.
>=20
> I am using ppp via a bluetooth modem.
>=20
> Trace:
> [22735.115313] PM: Syncing filesystems ... done.
> [22735.665613] PM: Preparing system for mem sleep
> [22735.665829] Freezing user space processes ...
> [22755.659538] Freezing of tasks failed after 20.004 seconds (1 tasks
> refusing to freeze, wq_
> busy=3D0):
> [22755.659555] pppd            D ffff8800376c9a58     0 16801      1
> 0x00000006
> [22755.659557]  ffff8800376c9750 0000000000000046 0000000000012e80
> 0000000000012e80
> [22755.659560]  ffff8802a1c1dfd8 ffff8800376c9750 0000000000000009
> ffff8802a1c1dd78
> [22755.659562]  0000000000000046 ffff8800376c9750 0000000000000028
> ffff8800376c9750
> [22755.659564] Call Trace:
> [22755.659569]  [<ffffffff81048507>] ? do_exit+0x937/0xa50
> [22755.659573]  [<ffffffff814bb6e1>] ? oops_end+0x91/0xd0

pppd can't be frozen because it crashed earlier in kernel mode.

[...]
> If you need any more info, I am happy to provide.

You should send the 'Oops' messages which should be further up the log
file.

Ben.

--=20
Ben Hutchings
Computers are not intelligent.	They only think they are.

--=-mu+P6VoeF++zp47Ncl5n
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUx4YWee/yOyVhhEJAQpnfBAArOzh0VLnqAsHTGFyLIsCjyqHCPhfDSto
nf4UodBFqt9o/RDaIiV6pzNf/ynF7+fGb+le98yLza25jEhPjmE8M/TWwLhKqc7a
gACN1J2+DHh7495ecQF4xE81t8d6GYnJRsBn4C5jiufL/CgWh9hODsGmeiZ9Iwoj
IICvODRCaQ3Fvu8dfvucy5ZjRextN3ABSBfd5GEX2qP90M9J/x5A57IL5aRG4uTt
JZowFZqodUwG2YlBQEMMP+T0MuS7RPtvpz8e44JVPtFbqvE2X94u5Y9yVVF+e+ik
69j+2snFWtlyno4g3YSXrgtr6b0MAX3k0oFmN1TL9p+cvJ8eNn12wMFLpatNzIUX
Hf0VBzMVYZqcFUHN3/msqrq/qOrU/DUxjA4Ae2vNWjkPiqUMpsAo3bKnYbH1j808
ptmNjm8jQICBHUBwXRfgsdFoqjNHoVvu/T+ndsC4GMWUW1UIgL9RBZx5bVX4MbMT
Dun185hUklWe0idY8EkAW1c0yJIJTpvc5ZP/xDYRywdoZO+mhjZAQOUftS8FNSqE
mZwkN/yLsKHycEbRDtQjADe5snD+zj/N+l7q1WfICEuYfozrr2+L0Yak7Wl7dhAz
1G6m7WVgstuxn4A60A1w1j9mok5iQTBPWYL8/9CMcFlNxOZnuRvfz0EgacTsl3W5
RF4dV8eFQe8=
=jZtd
-----END PGP SIGNATURE-----

--=-mu+P6VoeF++zp47Ncl5n--
