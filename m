From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH] add new nfnetlink_log subsystem
Date: Sun, 7 Aug 2005 17:03:58 +0200
Message-ID: <20050807150358.GD4855@rama.de.gnumonks.org>
References: <20050730103005.GB6620@rama.de.gnumonks.org>
	<20050807112039.GF10481@postel.suug.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="llIrKcgUOe3dCx0c"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20050807112039.GF10481@postel.suug.ch>
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


--llIrKcgUOe3dCx0c
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Aug 07, 2005 at 01:20:39PM +0200, Thomas Graf wrote:
> * Harald Welte <20050730103005.GB6620@rama.de.gnumonks.org> 2005-07-30 12=
:30
> > This (long-awaited) patch adds the generic nfnetlink-based userspace
> > logging.  nfnetlink_log can be used for any protocol family, and
> > supports upt to 65535 logging groups (that could go to separate logging
> > daemons, e.g.).
>=20
> Same very minor issues as nfnetlink regarding some of the
> new netlink message construction policies. I'll "fix" them
> during the conversion to the generic netlink attributes.

is this supposed to happen soon?  I also need to update the userspace
side in case you make any changes, so I'd appreciate any changes going
in ASAP.  Alternatively just tell me what needs to change and I'll
change it even before the generalization.

thanks

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--llIrKcgUOe3dCx0c
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC9iLeXaXGVTD0i/8RAhwpAKCLiKxxfNlyKw/sfSzQikQ+iWldYwCdEzyU
j2owmMcsKcD7FSlj2CzV4Pg=
=l5Bi
-----END PGP SIGNATURE-----

--llIrKcgUOe3dCx0c--
