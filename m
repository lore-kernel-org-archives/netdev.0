From: Harald Welte <laforge@netfilter.org>
Subject: Re: [RFC: 2.6 patch] the overdue removal of ip{,6}_queue
Date: Tue, 11 Apr 2006 20:26:24 +0200
Message-ID: <20060411182624.GD31616@sunbeam.de.gnumonks.org>
References: <20060409180105.GK8454@stusta.de> <44395505.1070608@trash.net>
	<20060411090139.GI5167@rama.linbit> <443BC06A.8020103@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="GpGaEY17fSl8rd50"
Cc: netdev@vger.kernel.org,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	Adrian Bunk <bunk@stusta.de>, coreteam@netfilter.org, sds@tycho.nsa.gov
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <443BC06A.8020103@trash.net>
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


--GpGaEY17fSl8rd50
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Apr 11, 2006 at 04:42:50PM +0200, Patrick McHardy wrote:
> > Maybe we should add a printk ('app foo is using obsolete ip_queue
> > system').
>=20
> Good idea, that will probably help speed it up. But I still think
> we need to give them at least another six month.

ok. I'll prepare a patch for both the printk and the update of
feature-removal-schedule.

> I think we need to do two things:
>=20
> - make libipq_compat a drop-in replacement that doesn't require
>   recompilation

libipq is not distributed as a shared library (at least not by us), so I
don't see any purpose for doing so.  Do you think anyone is going to
re-link statically linked code against the new lib

> - make it work with both ipq and nfnetlink_queue

that should be possible, though. =20

I still don't really think that it is worth all the effort, especially
since there is only one hand full of applications using libipq.

The backwards compatibility library is expected to perform a lot worse
thna both the old libipq as well as the new native libnetfilter_queue
due to additional data copies, etc.  When I wrote it, it was more
intended as some intermediate aid, something that helps while people
migrate.  We shouldn't make it too perfect, otherwise they won't migrate
at all.

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--GpGaEY17fSl8rd50
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3 (GNU/Linux)

iD8DBQFEO/TQXaXGVTD0i/8RAuZAAJ452DftSOTWxazNqeXxLl3WD0Y7IwCfXft1
pvmrIixEqpIXKW2S63KRaz0=
=AhMA
-----END PGP SIGNATURE-----

--GpGaEY17fSl8rd50--
