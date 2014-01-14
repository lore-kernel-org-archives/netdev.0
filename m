From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the tip tree with the net-next tree
Date: Tue, 14 Jan 2014 14:02:14 +1100
Message-ID: <20140114140214.7279bcaf88d7a4514d889186@canb.auug.org.au>
References: <20140113141824.4301cb76e8e5540d42d74015@canb.auug.org.au>
	<20140113142059.f9f1c58c391b2c8bbd05699f@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__14_Jan_2014_14_02_14_+1100_acrA+AyAj4P=aEp5"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Peter Zijlstra <peterz@infradead.org>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20140113142059.f9f1c58c391b2c8bbd05699f@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__14_Jan_2014_14_02_14_+1100_acrA+AyAj4P=aEp5
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

On Mon, 13 Jan 2014 14:20:59 +1100 Stephen Rothwell <sfr@canb.auug.org.au> =
wrote:
>
> On Mon, 13 Jan 2014 14:18:24 +1100 Stephen Rothwell <sfr@canb.auug.org.au=
> wrote:
> >
> > Today's linux-next merge of the tip tree got conflicts in
> > arch/arc/include/asm/Kbuild, arch/cris/include/asm/Kbuild,
> > arch/hexagon/include/asm/Kbuild, arch/microblaze/include/asm/Kbuild,
> > arch/parisc/include/asm/Kbuild and arch/score/include/asm/Kbuild between
> > commit e3fec2f74f7f ("lib: Add missing arch generic-y entries for
> > asm-generic/hash.h") from the net-next tree and commit 93ea02bb8435
> > ("arch: Clean up asm/barrier.h implementations using
> > asm-generic/barrier.h") from the tip tree.
> >=20
> > I fixed it up (see below) and can carry the fix as necessary (no action
> > is required).
> >=20
> > BTW: thanks for not keeping the Kbuild files sorted :-(
>=20
> I missed arch/mn10300/include/asm/Kbuild the first time round.

And ... git rerere does not work well here.  It stores resolutions by a
hash of the (sanitised) conflict and since most of these files have
exactly the same conflict, I am going to have to edit 5 of them by hand
every day.

Not happy :-(

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Tue__14_Jan_2014_14_02_14_+1100_acrA+AyAj4P=aEp5
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJS1Ki6AAoJEMDTa8Ir7ZwVtqcP/1WOrHDiX/sqRICnivK6m2I5
PaVt5Ng70rzsm8goudyBrX79dw1ObfuD+oE0yBTZFLVjb0NHPUzBt9hmLyGyQaU4
owQ/73gSmNSuY5YypPIDtQCYd5vq0ri5fynNIrofePqW1zKXaPH0ICvYwHB5AAJF
MWd8UTRuhPLAvGHysq+iY+yE8KuGMa9jKGOMunLmYxvYSzhGcsYQZ+kVKRxQblhQ
CzjhIeQnokXwjLmsSf0hKaNewY19e/G1UQ/2cPJwYqMLqCNCWjdZT/5DTtbg3+gH
yK29iqN5FGK+gQ2DH/QWYXIa/UrgBe9oGhSEevIj9UIV4HVUKG2jOZvhdI40a39l
ia+Oss0oVdUgIV06JZiMqBg97ong+SjR6BB+kBy0OuNvHMsW5inw8NRlzVrszPMM
Iz1pm00lBxE0nfoQgrVbNhos1C1zd9FAe3jHyAinhLFKTHR9R3cqatbeyvu5HKRA
IlzB9yec5o3vdJMPmpnX0K3/iZ+Fy5DLzE6mvj4woQuAzMQ/rI5gAxYuesGuJl46
9ohcLSM2+XbOHiHybTteXgbwgdK1wWNVMxonDkXf4nhBKjL+vwFvewyY2kQkh/Dd
bKXy68RCt1WkSbmsvCWZM1zPRAql9BOb8G6e71gb0eaKoZK9ylnXMG468w05DGSa
Dkt7jKlRglGMD+03PIDC
=KQf7
-----END PGP SIGNATURE-----

--Signature=_Tue__14_Jan_2014_14_02_14_+1100_acrA+AyAj4P=aEp5--
