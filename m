From: Harald Welte <laforge@netfilter.org>
Subject: Re: [Patch]: IPv6 Connection Tracking
Date: Mon, 29 Sep 2003 10:42:46 +0200
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <20030929084246.GE654@obroa-skai.de.gnumonks.org>
References: <1064515680.995.41.camel@localhost> <Pine.LNX.4.44.0309252151180.11253-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="SFyWQ0h3ruR435lw"
Cc: Andras Kis-Szabo <kisza@securityaudit.hu>,
	Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>,
	Netfilter Devel <netfilter-devel@lists.netfilter.org>,
	Netdev <netdev@oss.sgi.com>, usagi-core@linux-ipv6.org
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: Pekka Savola <pekkas@netcore.fi>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0309252151180.11253-100000@netcore.fi>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org


--SFyWQ0h3ruR435lw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Sep 25, 2003 at 09:57:47PM +0300, Pekka Savola wrote:
> First, a meta-comment:
>=20
> What I fear is that in the end, nothing gets done because having the goal
> set to perfection.  If there is no energy to drive through the
> L3-independent connecting tracking, the end result is that the user
> does not have this feature=20

well, that's the reason why I'd like to see it in=20

> (remember ip6tables REJECT target?  That must have been sitting in
> netfilter for some 2+ years, and not having been integrated in the
> mainline kernel and the users still do not have the feature!).

Mh, nobody has bugged me about that in all those 2 years.  At least I
don't remember somebody asking me for kernel inclusion...=20

Since ipv4 REJECT has now changed

> So, my personal take is:
>  - if a L3-independent conn tracking can be done *quickly*, fine,

I've started to write a small paper about the envisioned desgign.  It
doesn't look all that complicated, if somebody can concentrate on this
job.  I personally (as indicated before) do not have the time to work on
that issue.  But I'm happy to give advise.

>  - if not, just merge the current one, start working on L3 independent=20
> conn tracking, and add it when available.

I understand your point.  However, I fear to be the one responsible of
keeping ip6_conntrack in sync with ip_conntrack.  If there is a
volunteer (maybe Yasuyuki?) who would really commit himself to look at
which changes go into ip_conntack, and sending me patches to sync
ip6_conntrack, I'd be more inclined to submit ip6_conntrack to the
mainline kernel. =20

> .. but I'm not the one who's answering the support emails, so in all=20
> fairness, I should be silent now..

;)

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--SFyWQ0h3ruR435lw
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQE/d/CGXaXGVTD0i/8RAuZsAJ9+gG8tUawwy3u+4BTicBOkZdrZrgCfd7g2
k4SWLLMxIJc463EcS4hSfBM=
=SWcD
-----END PGP SIGNATURE-----

--SFyWQ0h3ruR435lw--
