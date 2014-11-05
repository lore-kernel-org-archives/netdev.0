From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [linux-nics] [PATCH net 3/5] fm10k: Implement ndo_gso_check()
Date: Wed, 05 Nov 2014 04:47:07 -0800
Message-ID: <1415191627.2420.61.camel@jtkirshe-mobl>
References: <1415138202-1197-1-git-send-email-joestringer@nicira.com>
	 <1415138202-1197-4-git-send-email-joestringer@nicira.com>
	 <1415190872.2420.55.camel@jtkirshe-mobl>
	 <CAJ3xEMjaQ54yEUQGL-8VHoPm=4G5bhPaGBa55jypzfKviR4KyQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ayRuV+g2gXZFjYVqwxW8"
Cc: Joe Stringer <joestringer@nicira.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux.nics@intel.com, shahed.shaikh@qlogic.com,
	sathya.perla@emulex.com, Amir Vadai <amirv@mellanox.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Dept-GELinuxNICDev@qlogic.com, Tom Herbert <therbert@google.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAJ3xEMjaQ54yEUQGL-8VHoPm=4G5bhPaGBa55jypzfKviR4KyQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-ayRuV+g2gXZFjYVqwxW8
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-11-05 at 14:44 +0200, Or Gerlitz wrote:
> On Wed, Nov 5, 2014 at 2:34 PM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
> > On Tue, 2014-11-04 at 13:56 -0800, Joe Stringer wrote:
> >> ndo_gso_check() was recently introduced to allow NICs to report the
> >> offloading support that they have on a per-skb basis. Add an
> >> implementation for this driver which checks for something that looks
> >> like VXLAN.
> >>
> >> Implementation shamelessly stolen from Tom Herbert:
> >> http://thread.gmane.org/gmane.linux.network/332428/focus=3D333111
> >>
> >> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> >> ---
> >> Should this driver report support for GSO on packets with tunnel
> >> headers
> >> up to 64B like the i40e driver does?
> >> ---
> >>  drivers/net/ethernet/intel/fm10k/fm10k_netdev.c |   12 ++++++++++++
> >>  1 file changed, 12 insertions(+)
> >
> > Thanks Joe, I will add your patch to my queue.
>=20
> Hi Jeff, please see my comment on patch 0/5, we're essentially
> replicating the same helper four different times (fm10k, mlx4, benet,
> qlgc) - I don't see the point in doing so. I asked Joe to come up with
> one generic helper and then to pick it up by the four drivers, makes
> sense?

Yeah, I just saw your reply Or.  Ok, I will await an update to Joe's
series, thanks!

--=-ayRuV+g2gXZFjYVqwxW8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUWhxLAAoJEOVv75VaS+3O2j0P/iRhdqcmPTnYzIf3VW67/Yt0
ncPl+QJXNN2lo8UH+hdVUxXuenRhFTFhwJBhCYxJMutmkgfnpU5SN7PZ/9wsk0Bx
Rnvtqid+2qqeEeQYmvX61jXySjQ7jgosNNVCDiPwhIcf7WNE3v2pIKLE+eXN1SPH
HogRqd+/PxkjFCV1NcPmXJwFZLqPOiTaonY5IeD7hDwX05HVssJHglKF+tnHoW2T
a6hCyeR+2QWyuToU55SmadRz7eSVyHnmGNXYkM7JokK8ofmCytwQCq3Sq70EqWCF
GIXqaUmX5H2wG2p4zvJkGytoYPhI+KyMxIrXKsm+d4N6CySlinOvWun7BotceYx3
9A3s2Iixw9bSav3JqFEPyoUm8zaAd2z72gJUlHBMAyciOxL2IkAbi19BYt8H3pRl
9Wbfs3gj60C2sq1AsFCQFpvyBVDq+WHtWrxLkKLmrGALr8ZHTpWE02SKelhSj9aj
4sCrcar2X8QRfRtRw/FjIGhzye4qAHPPKppjcViRUOj3DvrwmdkoPNd9+xpfoKmj
InrBEvaCwChHk63Xi7nZ8H3RAs/VjjkKa71UG5GARMzUeKhTfp4VcoQJbgoNHz++
1jeD5mZMnaletAcjtefo2HAbIRzCrvc6QU7xExXX6SuOi0UU7nNBssWytReJNWia
ETbxnEt0zTW93wJAMn5m
=WVkR
-----END PGP SIGNATURE-----

--=-ayRuV+g2gXZFjYVqwxW8--
