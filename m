From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the origin tree
Date: Mon, 7 Nov 2011 13:47:06 +1100
Message-ID: <20111107134706.3e7fc633f913b5e155153127@canb.auug.org.au>
References: <20111107101202.96fcb76d580e5265bd99aeee@canb.auug.org.au>
	<20111106.205259.1237400984015921904.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__7_Nov_2011_13_47_06_+1100_nTP_ql/QxCghs0ru"
Cc: torvalds@linux-foundation.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, gregory.v.rose@intel.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111106.205259.1237400984015921904.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__7_Nov_2011_13_47_06_+1100_nTP_ql/QxCghs0ru
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Sun, 06 Nov 2011 20:52:59 -0500 (EST) David Miller <davem@davemloft.net>=
 wrote:
>
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Mon, 7 Nov 2011 10:12:02 +1100
>=20
> > Starting with the origin tree, today's linux-next build (powerpc
> > ppc64_defconfig) failed like this:
>  ...
> > Caused by commit 9487dc844054 ("ixgbe: Fix compiler warnings") which hid
> > the declarations of ixgbe_disable_sriov() and ixgbe_check_vf_assignment=
()
> > when CONFIG_PCI_IOV is not defined.
> >=20
> > I have reverted that commit for today.
>=20
> It should be fixed in net.git, can you please check that the build
> succeeds after you pull it into -next?

I reverted the commit above ...

> If you just revert the commit in origin from -next, then you will get
> conflicts with you pull the net.git tree in.

I got no conflicts when I merged in the net tree and can see no fix for
this problem in the net tree.  My current head of the net tree is 1a6422f
"etherh: Add MAINTAINERS entry for etherh".

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Mon__7_Nov_2011_13_47_06_+1100_nTP_ql/QxCghs0ru
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJOt0aqAAoJEECxmPOUX5FEBlsP/jEbk8bU/lU+EnyVjk/gpI0M
xnFO0HqG/oGDEgBAq0Oi6I9OrWf5bPhu2brhdwHoQNcQGAxGc2KpJjLWBiVgJIha
j8meYwGDt1qDosjEU7bRszh3U9jyv7lyh7qXqL3hMwn8JhxLLCXyPARQmElpt1An
83y7h0xClyED7/TpxMm41gGfHJ+EYfNmZkASCr5AgItiUs6I3YedM+3UQV6gyXTu
Q/FXhTEKkc9DzaEAXjGNyBglGF5yH/Cf1c0Lo7GOKVNFShcKPfrpzVC2vSHyPboh
MKHpmQO4cNJ8cLGEvBL9uGvNT1zJnVkaoN/OtZResJrO7291MtgXbB6nWXIXDRoB
i46AtKoueuZN+Ata5P2oC7OSOauFvgs7wqu2S2FrUm0rzqwekaYCZXq1ndJPPFAr
hLXhfM7D6KP4g4eVWeMI8h9m1YlqZqEsOc8CuOkXv700Expjd2yU/VT9wkN2rJ+c
0li7P6Jxrvh/W17mqZtOm/Pay6KqzIimB9YNd7826q2f059EDQtmDuxdWiZ+sYVC
aEBhXeSmC4KCdT9iO6D4orTHELL6yhO4HAuNajfYmbzAlZE1B5qSbUxQIk+Y/Bzi
X7N//fkt1eB0mA/Jg885OcTZfOw0cAMtVcYKgwMAGsK4/l2uli5P7N36G3pvM29J
j0iK4Z+T8jrSrKjRtUUI
=Gtzj
-----END PGP SIGNATURE-----

--Signature=_Mon__7_Nov_2011_13_47_06_+1100_nTP_ql/QxCghs0ru--
