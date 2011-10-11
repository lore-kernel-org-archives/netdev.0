From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the tip tree
Date: Tue, 11 Oct 2011 17:15:04 +1100
Message-ID: <20111011171504.8bc948ec0daf2d4ed28e562f@canb.auug.org.au>
References: <20111005172528.0d0a8afc65acef7ace22a24e@canb.auug.org.au>
	<1317804373.6766.0.camel@twins>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__11_Oct_2011_17_15_04_+1100_VCtL9akY6EoH_UjA"
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	"H. Peter Anvin" <hpa@zytor.com>, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1317804373.6766.0.camel@twins>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__11_Oct_2011_17_15_04_+1100_VCtL9akY6EoH_UjA
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

On Wed, 05 Oct 2011 10:46:13 +0200 Peter Zijlstra <peterz@infradead.org> wr=
ote:
>
> On Wed, 2011-10-05 at 17:25 +1100, Stephen Rothwell wrote:
> >=20
> > After merging the tip tree, today's linux-next build (x86_64 allmodconf=
ig)
> > failed like this:
> >=20
> > net/rds/ib_rdma.c: In function 'rds_ib_reuse_fmr':
> > net/rds/ib_rdma.c:272:2: error: implicit declaration of function 'llist=
_del_first' [-Werror=3Dimplicit-function-declaration]
> > net/rds/ib_rdma.c:272:6: warning: assignment makes pointer from integer=
 without a cast [enabled by default]
> > net/rds/ib_rdma.c: In function 'rds_ib_flush_mr_pool':
> > net/rds/ib_rdma.c:671:4: error: implicit declaration of function 'llist=
_add_batch' [-Werror=3Dimplicit-function-declaration]
> > cc1: some warnings being treated as errors
> >=20
> > Caused by commit 1230db8e1543 ("llist: Make some llist functions inline=
")
> > interacting with commit 1bc144b62524 ("net, rds, Replace xlist in
> > net/rds/xlist.h with llist") from the net tree.  The former commit
> > removes the declarations of llist_del_first() and llist_add_batch() with
> > no explanation (and probably by accident since the definitions still
> > exist).
>=20
> Ugh yes, my bad. Ingo objected to inlining all those functions and I
> then screwed up. There are no users of those two functions in my tree.

So can we have that fixed, please?

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__11_Oct_2011_17_15_04_+1100_VCtL9akY6EoH_UjA
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJOk97oAAoJEECxmPOUX5FEuMMP+gPW7VHPEi1TbgW2IkpxlSRi
Jto4vpmF1E3ibqFAFSzemAC/XyIPtiAFdKSD/8LjM6QR7tNKfQm7UoeKKdr8B9gX
aXV7fvhjUNir1KHxDSghHX8ENu072voqWkngz5azg9E0ntDZMzRKJVvtGCZNWAzK
jjZKz+cC2oY+cEj3yUS62CM4HvfoxNjNbvfSmmYXo0oKWtj+jLfDQeto8uayoHSn
68CdWik3MkXbVbCRJM7ynl0TKf6MoJYTRFFqBuX0Ho3brLZk6TUO1LgcPWkztFrN
1hrq3GxJIZv620IzQtJRg4EFP7Rx8M8nIe/kmNVeFEEPbzfMjghUijwuhhomTwMo
ZhHAxkNJSRa5h1BwhLIrTWFrmT/YPEhuVrSF3z5BHtLE5SkurjQq0I16TJkV36iA
dX4f5C+kLAxJ4cIuPFE++fZICVoT/R0WTLR1w+90Mu+2DmCC4fpBN4DfCZpB7raK
7YIgSERLg+0YyKhWZfnyvOQ9IOvjyy8q6lU79TmssbTlR1/R4wSwsgvzq8eavMA3
NArAD+97nog0h5joKz9TCb+syz0meiItVAzaNShs4qs2n/tprTpKFn7tH8wjWbSF
vfsG2nQYk7psBN0vwBk0ijM9qVYsx5VoOt4wIdEjooL/AGPwJmY5AMGUPqlxBLVh
sBY3cUCY4dORB5MHJl5B
=2SH1
-----END PGP SIGNATURE-----

--Signature=_Tue__11_Oct_2011_17_15_04_+1100_VCtL9akY6EoH_UjA--
