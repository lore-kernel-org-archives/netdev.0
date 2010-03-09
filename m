From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH] ar9170: fix for driver-core ABI change
Date: Tue, 9 Mar 2010 12:52:45 +1100
Message-ID: <20100309125245.c25e5ca4.sfr@canb.auug.org.au>
References: <20100309104221.aedc5e7e.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__9_Mar_2010_12_52_45_+1100_Ay92DLu+zl5zo5f."
Cc: "John W. Linville" <linville@tuxdriver.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-next@vger.kernel.org
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100309104221.aedc5e7e.sfr@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__9_Mar_2010_12_52_45_+1100_Ay92DLu+zl5zo5f.
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Tue, 9 Mar 2010 10:42:21 +1100 Stephen Rothwell <sfr@canb.auug.org.au> w=
rote:
>
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> ---
>  drivers/net/wireless/ath/ar9170/usb.c |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
>=20
> I have been carrying this patch in linux-next for some time as a fixup
> for the driver-core tree.  It is now needed in net-2.6 (i.e. my
> net-current) (since you merged the wireless tree) *after* you merge with
> Linus' tree i.e. the down()/up() are present in the net-2.6 tree and the
> changes to the driver core to use mutexes are in Linus' tree.

Greg tells me that the semaphore to mutex change didn't go into Linus'
tree.  However, this patch can still be applied as the device_lock/unlock
primitives did go in.  I guess that the include of mutex.h is not needed.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__9_Mar_2010_12_52_45_+1100_Ay92DLu+zl5zo5f.
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkuVqe0ACgkQjjKRsyhoI8y6ogCggC5fH9B98EKDHvLEM5it76al
ZrMAn2xyC2pw9bepvBAoWMLxD2tBgHei
=tAvG
-----END PGP SIGNATURE-----

--Signature=_Tue__9_Mar_2010_12_52_45_+1100_Ay92DLu+zl5zo5f.--
