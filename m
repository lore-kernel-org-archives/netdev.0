From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH] [NETFILTER] nfnetlink_log: add sequence numbers for log
	events
Date: Tue, 31 Jan 2006 09:54:42 +0100
Message-ID: <20060131085442.GJ4603@sunbeam.de.gnumonks.org>
References: <20060130232348.GH4603@sunbeam.de.gnumonks.org>
	<43DEA205.7020704@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ONcvOehchf6uZUM5"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <43DEA205.7020704@trash.net>
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


--ONcvOehchf6uZUM5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jan 31, 2006 at 12:32:21AM +0100, Patrick McHardy wrote:
> Harald Welte wrote:
> > Hi Dave,
> >=20
> > please apply, thanks!
> >=20
> > [NETFILTER] nfnetlink_log: add sequence numbers for log events
> >=20
> > By using a sequence number for every logged netfilter event, we can
> > determine from userspace whether logging information was lots somewhere
> > downstream.
>=20
> BTW, I have a patch I wanted to submit on top of this, which changes the
> *LOG targets to do "reliable" logging, which means if we encounter any
> errors during logging (for example from netlink), the packet will be
> dropped. This makes as sure as possible that no connections will be
> silently accepted. Its a slight change of user-visible behaviour, but
> since it only affects corner-cases I think it should be OK. I could add
> some flags to retain the current behaviour, but I think its not worth
> it.=20

I think it is very much required to have such a flag.  (we can actually
add it to the nfnetlink_log flags).  It really depends on your setup.
Some people really really want to have logging reliable, others fear
that they might easily be DoS'ed, if logging has higher priority than
packet forwarding.
=20
> Any objections?

If it's optional (and the default is unreliable), then I think it's a
great idea.

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--ONcvOehchf6uZUM5
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQFD3yXSXaXGVTD0i/8RAqaVAJ4qQ+QUe5QabgdBftYcz58cCaj3gwCgpHky
2DFyxWUmTIthVlPIeKOviEE=
=gVcC
-----END PGP SIGNATURE-----

--ONcvOehchf6uZUM5--
