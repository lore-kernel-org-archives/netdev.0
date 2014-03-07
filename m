From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e1000: do not allow watchdog to reenable transmits on
 shutdown
Date: Thu, 06 Mar 2014 19:24:31 -0800
Message-ID: <1394162671.2214.36.camel@jtkirshe-mobl>
References: <20140307020420.GA10797@amt.cnet>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-10HjuCGbv7eSYTTztPKo"
Cc: Vladimir Davydov <VDavydov@parallels.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Marcelo Tosatti <mtosatti@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:40220 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751013AbaCGDYr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2014 22:24:47 -0500
In-Reply-To: <20140307020420.GA10797@amt.cnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-10HjuCGbv7eSYTTztPKo
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-03-06 at 23:04 -0300, Marcelo Tosatti wrote:
>=20
> There is a race on the shutdown path of the e1000 driver
> that allows the card to DMA into free'd memory.
>=20
> The symptoms are similar to those described at=20
> commit d5bc77a223b0e9b9dfb002048d2b34a79e7d0b48,
> "e1000: don't enable dma receives until after dma address has been
> setup", where memory corruption is visible due to E1000_RXD_STAT_DD
> being written to the DMA transfer descriptor.
>=20
> Fix by not allowing the watchdog and tx fifo stall detector
> to re-enable E1000_TCTL_EN.
>=20
> Signed-off-by: Marcelo Tosatti <mtosatti@redhat.com>

Thanks I will add this to the queue.

Note- there are trailing whitespace issues and 2 comments are not
formatted correctly.  I can fix these up if there are no other issues
with the patch, if you want.

--=-10HjuCGbv7eSYTTztPKo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJTGTvvAAoJEOVv75VaS+3OWFIQAKBZKPUKjJbFIFAjawbd74jO
RMCBoxOXpKVEUUrvlA9r536IijUSQ/AZ4nNaspYUNXEy/kOVUI3QlrFejIclPWIe
y1wTF90zf4nMgkcv36D5ujfe73FX+dQCBUtcskRj9EUAAIKWfE/L5HJ3Crzrbhtj
Z6ndz1D7fluaSCIa0y+j3GI3+CeFjyq4CtlB1lMGTRBx+yw/iQ894okBOj/8kb/j
kQqzYwfNVpmBHzkjgIGMVHFMLoF6HrsU/IdoYfC4IjnnfNyiNo42aheQz99lBwze
vgOzuW/gVNocjv8zFsvSQz08KIXUT68LAyyhinTs1uTTyit2cGnpF3jXStbfV8r5
M+B7PQRSIAZNyxJ++H5AnboVhKZ09rkl2rKjQyOSRLu72PjDoEyWENOTmxf+Sh3u
VpxfbCHYxPv0hiBabsFYYMDYQeSoCB4IDT1SZ1zSpa4/vnsLOMN4ItW5BVrloocU
UIWTcSS9s+AkKiyBs0MRutGTpg24mOa/8BWiOP8OroR3aj5T4/sRgBesVV7RKc61
Mhnc0b7CM15b/ev3qATkpnDbBBFlzXkiQKaXJK7PzHlz+ApLQCAGWYE1/LXcaN7R
B5gkJmXm6s+YN/v3HI8S8tm3yx0hdyBZPme5WtE8jb0IsWf+/kg16oeCdmDvH/u9
F21QJHHRl0C6st3rAmkN
=VEhp
-----END PGP SIGNATURE-----

--=-10HjuCGbv7eSYTTztPKo--
