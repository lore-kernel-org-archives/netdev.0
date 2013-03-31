From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Bug#565404: linux-image-2.6.26-2-amd64: atl1e: TSO is broken
Date: Sun, 31 Mar 2013 00:25:58 +0000
Message-ID: <1364689558.3557.22.camel@deadeye.wl.decadent.org.uk>
References: <CDAFEDABF718A54BABD0DA5476695307475CCD42@SHEXMB-01.global.atheros.com>
	 <20100125.163612.582489483209420341.anders@netinsight.net>
	 <CDAFEDABF718A54BABD0DA5476695307475CCFF8@SHEXMB-01.global.atheros.com>
	 <20100126.093439.651115405791675606.anders@netinsight.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-kBB26I2cLbeoGPvmJBBY"
Cc: Jie.Yang@Atheros.com, netdev@vger.kernel.org,
	565404@bugs.debian.org, Xiong.Huang@Atheros.com
To: Anders =?ISO-8859-1?Q?Bostr=F6m?= <anders@netinsight.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:54200 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754711Ab3CaA0M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Mar 2013 20:26:12 -0400
In-Reply-To: <20100126.093439.651115405791675606.anders@netinsight.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-kBB26I2cLbeoGPvmJBBY
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2010-01-26 at 09:34 +0100, Anders Bostr=C3=B6m wrote:
> >>>>> "JY" =3D=3D Jie Yang <Jie.Yang@Atheros.com> writes:
>=20
>  JY> Anders Bostr=C3=B6m <anders@netinsight.net> wrote:
>=20
>  JY> following is my test cese,
>  >>=20
>  JY> a nfs server server with ar8131chip, device id 1063.
>  >> export /tmp/ dir as the nfs share directory,  JY> the client,
>  >> mount the server_ip:/tmp to local dir /mnt/nfs, ust a python
>  >> script to write and read data on the  JY>
>  >> /mnt/nfs/testnfs.log. it works fine.
>  >>=20
>  >> OK, the device-ID in our NFS-server is 1026, rev. b0. So it
>  >> is possible that the problem is specific to that chip/version.
>  JY> oops, its my mistake in writing, my case is 1026 device ID
>=20
>  >>=20
>  JY> Can you give me some advice on how to reproduce this bug??
>  >>=20
>  >> The only suggestion I have is to try to find a board with a
>  >> 1026-chip on it.
>  >>=20
>  >> My test-case is just copy of a 1 Gbyte file from the
>  >> NFS-server to /dev/null , after making sure that the file
>  >> isn't cached on the client by reading huge amounts of other data.
>  >>=20
>  JY> just to check, if the kernel version is 2.6.26-2 ??
>=20
> I've tested with
> Debian linux-image-2.6.26-2-amd64 version 2.6.26-19lenny2,
> Debian linux-image-2.6.30-bpo.2-amd64 version 2.6.30-8~bpo50+2 and
> kernel.org 2.6.30.10 amd64 with ethtool patch for setting of tso. Same
> result.

Does booting with the kernel parameter 'pci=3Dnomsi' avoid the problem?

Ben.

--=20
Ben Hutchings
Teamwork is essential - it allows you to blame someone else.

--=-kBB26I2cLbeoGPvmJBBY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUVeClue/yOyVhhEJAQojDg/+Jkby0zd9fI5BXyVe8z8OCZRnKlXnOP/Z
3Lv8J+GnUvDe7ZDF4qnhFl4B3u7kGe+TFH43ytt094PYi0Zw5A9/pREXLdPRfLtQ
tsFtLrvh1pdmcUpV2YxM/CcjmYdg/mHgFlqKM6OkCEWsgHN5yc02anh/mvyXuKOx
riJlva1bawdX63gmJ9RxvMQtd/VY9lJd6b1yzsbcavWC2IxZrKON5D89HLuTefFH
tOWDula1KdhtGyGCB1/flC8s0NjB/jSs9aNDtaPh5Zb4DiBtLrjt3JDgWHgUY+Yz
E5SC1C+GOLGPZFxmak4bNJxMJ1gw+dFcburxGjt6lMI64qbWCiRv0PW/czL2eCET
FNrhKDJlWtfmpf3YBIzk3CF9FtSa2KhOCSsbTr2BFBSvf/Hoyh2x+nxAIk4z7ECN
+N6wj9+zddfDTtaPf/kP81sJfdx5q6q3Wxjkkigy4WGZGS07MQu2oLfxvpl0LTLH
mWJGXXTXPWAT4HuflBmCoRf3QgCvQ4IyDLZwyBSsCX5ivhYOtH/5hXDahf6akR4L
2EkrZgODmkhfkGOzmeWxAtm+CiJMl7dODgCbC2+YdUAPQ6V101BZlV1bssD4AJZE
MnJIIao+KwZql2B6CIECOvP3G6izt94mPVJRW8/sp3z9qRzkYWmFBmFTNbt+5npQ
t1gSHxEPw/g=
=w0hV
-----END PGP SIGNATURE-----

--=-kBB26I2cLbeoGPvmJBBY--
