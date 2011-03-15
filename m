From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Tue, 15 Mar 2011 17:25:58 +1100
Message-ID: <20110315172558.a11642e7.sfr@canb.auug.org.au>
References: <20110314170546.af552b4e.sfr@canb.auug.org.au>
	<alpine.LFD.2.00.1103141053020.2787@localhost6.localdomain6>
	<20110315113049.a6112494.sfr@canb.auug.org.au>
	<20110314.210712.226761233.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__15_Mar_2011_17_25_58_+1100_A9q7I7Rrqzjfrpl8"
Cc: tglx@linutronix.de, bhutchings@solarflare.com,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, hpa@zytor.com,
	peterz@infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110314.210712.226761233.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__15_Mar_2011_17_25_58_+1100_A9q7I7Rrqzjfrpl8
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Mon, 14 Mar 2011 21:07:12 -0700 (PDT) David Miller <davem@davemloft.net>=
 wrote:
>
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Tue, 15 Mar 2011 11:30:49 +1100
>=20
> > So, if you merge the commit 1fb0ef31f428 ("genirq: Fix affinity notifier
> > fallout") from the tip tree, you will get exactly one new commit and wi=
ll
> > fix your tree properly with no adverse effect on anyone else.
>=20
> Thomas, how would you like me to do this?  Do you want to put that
> commit on a branch for me to pull from or should I apply it
> directly?

That commit is already the head of the irq/numa branch in the tip tree
(it is also on the irq/core branch).

Please merge that rather than cherry-picking the commit as that will
minimise the possibility of conflicts.  Pulling the irq/numa branch will
get you just that one fixup commit (as you have already merged up to the
immediately preceding commit).

I assume this makes sense, Thomas?  I just did a merge of the actual
fixup commit after merging the net tree.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__15_Mar_2011_17_25_58_+1100_A9q7I7Rrqzjfrpl8
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJNfwZ2AAoJEDMEi1NhKgbsBhUH/2Q0eutJOLr3TszlJVE8vbj+
cc2EzZRR21k+DmXAp5Sj3jGTWN9/7VvWEn7qCHG70ikVvH14eqTlQ6EKfGQQjVUT
qFte4eYolxUm3RSefXafAt2CeUMWTZPBngd5oGCGPDLVRxIr5iIJfnDLdSyxP+qV
agfW1QlS8ixGF9hh/oTb7aAWkZxmOx3Gb19jZTSQiblGtVUC84YdCCJmpT179BOm
zPs8mndSA1fMXyG0isA02tt0f1yUR11pPb4huR8fgAHPsRtCfFZPUbT57QbyKL6o
4J6AdXU+IglXxoRHimsrTfH5dUcJxy+vVy9/9O0tqcgA+4DhscBuGxqtDpgYjbA=
=xZOY
-----END PGP SIGNATURE-----

--Signature=_Tue__15_Mar_2011_17_25_58_+1100_A9q7I7Rrqzjfrpl8--
