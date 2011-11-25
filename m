From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH 2/4] NET: NETROM: When adding a route verify length of
 mnemonic string.
Date: Fri, 25 Nov 2011 14:36:03 +0300
Message-ID: <20111125113603.GN3258@mwanda>
References: <cover.1322214950.git.ralf@linux-mips.org>
 <cfff1df64b18a89140ff995189c6a3c484815997.1322214950.git.ralf@linux-mips.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="D9sZ58tf58331Q5M"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org, Walter Harms <wharms@bfs.de>,
	Thomas Osterried <thomas@osterried.de>
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <linux-hams-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cfff1df64b18a89140ff995189c6a3c484815997.1322214950.git.ralf@linux-mips.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--D9sZ58tf58331Q5M
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Nov 25, 2011 at 09:08:49AM +0000, Ralf Baechle wrote:
> struct nr_route_struct's mnemonic permits a string of up to 7 bytes to be
> used.  If userland passes a not zero terminated string to the kernel addi=
ng
> a node to the routing table might result in the kernel attempting to read
> copy a too long string.
>=20
> Mnemonic is part of the NET/ROM routing protocol; NET/ROM routing table
> updates only broadcast 6 bytes.  The 7th byte in the mnemonic array exists
> only as a \0 termination character for the kernel code's convenience.
>=20
> Fixed by rejecting mnemonic strings that have no terminating \0 in the fi=
rst
> 7 characters.  Do this test only NETROM_NODE to avoid breaking NETROM_NEI=
GH
> where userland might passing an uninitialized mnemonic field.

Good point...  I missed that.

Acked-by: Dan Carpenter <dan.carpenter@oracle.com>

regards,
dan carpenter


--D9sZ58tf58331Q5M
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJOz32iAAoJEOnZkXI/YHqRR00P/RP3ewBqB9iNzbVij23Q9sb7
ChGW8O7JLuvPEjGb6DCcRfeFTNiyOR3IqWe5SYyxNzv1V0rcPWHNYcFRig0B4WfY
TdJqtCJho3qQq0jMBHlwXvU1e/beR5r0LQ5pbMXFV3L5GMTiQ6fdGbWDw8v3ht2K
eMqwVZl+MqJ5pK0cqjDqs6x0DTx9L+jV8kKiz+YCdmIheSCdc1Uq10ZZ6lHiuQ0o
vpURYF8oRiYuxNZDE8ykajDHLfJV5kP2AJIZBBy57eQ8XCuCn99TCRm/qGzJloGE
zShSYGlrjxPrORXnCY2pRgyz6FxENx8Jd/1JguPbpSOBLZxQ2KYsYz32VMbSdE6c
7Yzn1pFjYsZnl681uOJpSZY2TPUH9uPR43uDL3oolForBa+0pSPQdG3NhbifkVIv
/kb0RaSLaMUlz+P8UXMG4q/voMeLipPDoCegsm4I+nAsCtQkFaOef7b9kX+GfNAP
QfHokVkHlw4M3KQMORL7K6t83ntbtRhhTPnjKhxKY6vmn+p8Qp4wBtlwAldjpLTE
OmSU0RnsmCtzolpYk5rGQSS1+ThukXYqzR0uZG0ynN8XcYVNf1OBjIKpWt8i0YGH
TbkFCvZkfNRdXDKiEOIEJ7gk9/d763KMLE9Zbax7iLbDzB5mN5y/sFvcpekpMrKK
wLAp5NfQddl90yglKhhk
=rvAZ
-----END PGP SIGNATURE-----

--D9sZ58tf58331Q5M--
