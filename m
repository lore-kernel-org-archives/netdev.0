From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Bug#644281: linux-image-3.0.0-1-amd64: problem after changing
 mtu size on jme kernel module
Date: Fri, 07 Oct 2011 05:17:52 +0100
Message-ID: <1317961087.4024.28.camel@deadeye>
References: <20111004181353.3212.57206.reportbug@ASUS>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-WyfjlBB64h7JF2/SXxb5"
Cc: 644281@bugs.debian.org, kantacki <kantacki@o2.pl>,
	netdev <netdev@vger.kernel.org>
To: Guo-Fu Tseng <cooldavid@cooldavid.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:40800 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751107Ab1JGESa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 00:18:30 -0400
In-Reply-To: <20111004181353.3212.57206.reportbug@ASUS>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-WyfjlBB64h7JF2/SXxb5
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2011-10-04 at 20:13 +0200, kantacki wrote:
> Package: linux-2.6
> Version: 3.0.0-3
> Severity: important
> Tags: upstream
>=20
> Hello,
>=20
> When I try to execute:
> ifconfig eth0 mtu 4000 up
> or
> ifconfig eth0 mtu 7198 up
> my nic stops working and changing back to mtu 1500 does not help.
> To use my nic again I have to execute:
> rmmod jme
> modprome jme
> and the the command ifconfig eth0 mtu 1500 $IP up works and enables the n=
etwork
>=20
> My network card is Jmicron
[...]

Can you look into this, please?

It appears that jme_change_mtu() doesn't stop the RX path and doesn't
immediately reallocate RX buffers, and I think it should.  Maybe that's
not the problem though.

Ben.

--=20
Ben Hutchings
For every action, there is an equal and opposite criticism. - Harrison

--=-WyfjlBB64h7JF2/SXxb5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATo59cOe/yOyVhhEJAQq5fhAAqfHqVRIMWtWtvdFfKGGdKX6cHxhmLqlS
ikjVgoFD0mJkmPYa8DcRNsrRmvrSHNHjVsK5s6MXrXfyuC0ld/scffTkkWVxMzoE
6jxBI6LXmEZQ7HxPU7/6ZFD3t5LUg4+IgsORZ7TQSBsojiXgEEQqM/KIVQKiMtYf
685UWuItYo3VGqtLzxwwxu9CESTokDTdm5nAMZ7CaeoVS/RsNS25b+O4av6aj+q7
TsCXNINKK+aml4D3YZWZbzSEez4fWbjLdprReC1xm79mKymThGbN7YCDTcAhtjZd
blrA70egk5m9c4I8TmH8O/IPHYRM3MEiOQ3K8wQNWEjwKEgKXIOcpxPX87+5TybL
mwbEHFj9ThWy8JpNGP4hNGD+P9MLYM7B2hUkojMf2jsXlOq5IFq1yzSla2RoV3JW
FDqYY2zH995AR5WZqntZAK97dm3Lc2Gi7qOi49853tyuktx5vStuDwahbGUPw8Nq
QU5clupD0e/IHdQEsuNYR0OTgjdWqJTp4p6AqBUU+4vFleLaVxMhaEHf2axmF229
ISol6AFHB0b84u4Sit/Zrk7qEfOLYQmUv/4iLuLXSobcLvYDHfRgPfnvzs2eWUpg
IZqwwg27TYAQ2B2GzRbrS505ToRe1Bl0hCO3Qf492OPT62NPsx7SLMOdFbr9llsR
LcQN7YtnQzc=
=y5t/
-----END PGP SIGNATURE-----

--=-WyfjlBB64h7JF2/SXxb5--
