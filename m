From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the tip tree with the net-next tree
Date: Tue, 14 Jan 2014 16:19:04 +1100
Message-ID: <20140114161904.8210a95bb76d45ef4405d628@canb.auug.org.au>
References: <20140113141824.4301cb76e8e5540d42d74015@canb.auug.org.au>
	<20140113142059.f9f1c58c391b2c8bbd05699f@canb.auug.org.au>
	<20140114140214.7279bcaf88d7a4514d889186@canb.auug.org.au>
	<52D4C25F.8060804@zytor.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__14_Jan_2014_16_19_04_+1100_CrV1NnNumyvu=m1J"
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <52D4C25F.8060804@zytor.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__14_Jan_2014_16_19_04_+1100_CrV1NnNumyvu=m1J
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Mon, 13 Jan 2014 20:51:43 -0800 "H. Peter Anvin" <hpa@zytor.com> wrote:
>
> On 01/13/2014 07:02 PM, Stephen Rothwell wrote:
> >=20
> > On Mon, 13 Jan 2014 14:20:59 +1100 Stephen Rothwell <sfr@canb.auug.org.=
au> wrote:
> >>=20
> >> On Mon, 13 Jan 2014 14:18:24 +1100 Stephen Rothwell <sfr@canb.auug.org=
.au> wrote:
> >>>=20
> >>> Today's linux-next merge of the tip tree got conflicts in=20
> >>> arch/arc/include/asm/Kbuild, arch/cris/include/asm/Kbuild,=20
> >>> arch/hexagon/include/asm/Kbuild,
> >>> arch/microblaze/include/asm/Kbuild,=20
> >>> arch/parisc/include/asm/Kbuild and
> >>> arch/score/include/asm/Kbuild between commit e3fec2f74f7f
> >>> ("lib: Add missing arch generic-y entries for=20
> >>> asm-generic/hash.h") from the net-next tree and commit
> >>> 93ea02bb8435 ("arch: Clean up asm/barrier.h implementations
> >>> using asm-generic/barrier.h") from the tip tree.
> >>>=20
> >>> I fixed it up (see below) and can carry the fix as necessary
> >>> (no action is required).
> >>>=20
> >>> BTW: thanks for not keeping the Kbuild files sorted :-(
> >>=20
> >> I missed arch/mn10300/include/asm/Kbuild the first time round.
> >=20
> > And ... git rerere does not work well here.  It stores resolutions
> > by a hash of the (sanitised) conflict and since most of these files
> > have exactly the same conflict, I am going to have to edit 5 of
> > them by hand every day.
> >=20
>=20
> Well, you probably can keep a diff from the conflict-merge tree to the
> fix, but still.
>=20
> Is there a sensible way we can fix this in either net-next or tip?

Probably not now.  If the respective patches had kept those Kbuild files
sorted, then (most of the) conflicts would not have happened.

Maybe if there were follow up patches that put them back in order it may
help.  Or at least maybe make the conflicts different enough so that
git rerere would store them all.

I am just grumbling because I guessed this would happen when I saw the
patch go into the next-next tree (unfortunately, it was a report of mine
that caused that patch to be created :-().
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Tue__14_Jan_2014_16_19_04_+1100_CrV1NnNumyvu=m1J
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJS1MjQAAoJEMDTa8Ir7ZwVhDQP+QENUOHct7sgu/HgvOzCgAK7
R6sDGbWqtjRBxSo79qyaXwl0LL9cj/7rMnmMB6PBGfv3dFz+Ir3HfCcCI6V7i2fu
K9SPBFy6iU+PjC1Eu4/QPXNIsEojkMc9ZkL+boPH0Jo4w4XtW8CVgL0UzcnyVx0l
dkCPm4jf3/8oqk6anNhC4Mm3fGaElPLAGIwWNNbChdFAQjMfg7PhSqr/scW7nw7v
zErt6PX0j4ZL3ekCrsWh4pdb+anky8G4zPBxdV9MicGfwO7bEhbWUobAHtm60qeY
LiHSW+2vnhIUwuXO4xj5H2WxucLYslHUH5aEnV5yQ7LRYO6GrtvUSCZXL/id3KcH
+tb3gJm+iqHFGBDEMj4uYiAYGfChmpepDI+Ua9aI3P+dPDlaMo8WQGg2sIKnG5An
Om8Q8l6lLcscSf9xaYyhyzqhtGKfUr20JVbe+aHZCz/aK80P5XxofLj0eeZ4/x4R
JEZgxbYES279VH7uvF06TivaXfEQBR+I28w090IZ6sTiQzqVipYGtFgts1axBmB2
Fcnaopu5kvJQuaebJ7U7+AMkWM9cTM95ZdJSlxCz9AbHmkyxRALyEFGNxZUMYuD5
x1bZsqCSfnr0s0lbuN5eR2Ni/uLzQMqffqVLeI6wwa2yq2njdeRgSDE2V6ZRldiJ
es9jgJj97BqVs3FoxQJZ
=b0uq
-----END PGP SIGNATURE-----

--Signature=_Tue__14_Jan_2014_16_19_04_+1100_CrV1NnNumyvu=m1J--
