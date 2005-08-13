From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH] add new iptables ipt_connbytes match
Date: Sat, 13 Aug 2005 16:50:23 +0200
Message-ID: <20050813145023.GA4551@rama.de.gnumonks.org>
References: <20050812153730.GR18580@rama.de.gnumonks.org>
	<20050812182355.GF22901@wotan.suse.de>
	<20050812190343.GW18580@rama.de.gnumonks.org>
	<20050812.120904.88476024.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="17pEHd4RhPHOinZp"
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	kaber@trash.net, ak@suse.de
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050812.120904.88476024.davem@davemloft.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--17pEHd4RhPHOinZp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Aug 12, 2005 at 12:09:04PM -0700, David S. Miller wrote:
> From: Harald Welte <laforge@netfilter.org>
> Date: Fri, 12 Aug 2005 21:03:43 +0200
>=20
> > Ok, I hope everyone is fine with this patch:
>=20
> It is, but I did not add the connbytes patch into my tree so I can't
> use this patch as-is.  That's why I replied "this is broken, fix u64
> alignment" to the connbytes patch instead of "applied, thanks" :-)
>=20
> Please untangle this stuff.  This is how we end up with a big mess of
> noise changesets in the tree, due to how we have been putting
> half-working changes in first then a bunch of "fixup" patches.  I'd
> like to avoid that, because I then spend a lot of time redoing things
> when I rebase the tree later.

Fine, I can understand that in the case of the connbytes/unaligned case.

Speaking more generally:
I know I've been the exact opposite with all the nfnetlink_* stuff.
But the problem is to a certain degree that bugs aren't discovered until
it's in some tree that a lot of people use...

I think our whole usual strategy 'put it in patch-o-matic and wait until
bugs have been shaken out' doesn't really work because there's too
little people actually using the code from there.

So for new development, I'm now more inclined to push things sooner to
you - even more for code that only adds new featurss. If you generally
dislike that, please let me know.

> So in this case, send me the aligned_u64 patch seperately which
> doesn't assume connbytes is in the tree.  Then another patch which
> adds connbytes with the proper usage of aligned_u64.

sure.  no problem. Will be sent soon.

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--17pEHd4RhPHOinZp
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC/givXaXGVTD0i/8RAgboAJ4rUm7woUxOv50TKb+no7f/e5IINACgqztX
2WIQfULbUPU2kXx0L9ui2I4=
=6wF5
-----END PGP SIGNATURE-----

--17pEHd4RhPHOinZp--
