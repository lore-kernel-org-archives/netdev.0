From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH 2.6] fix deadlock with ip_queue and tcp local input path
Date: Thu, 26 May 2005 22:58:31 +0200
Message-ID: <20050526205831.GL13114@sunbeam.de.gnumonks.org>
References: <20050526142420.GD13114@sunbeam.de.gnumonks.org>
	<20050526.135229.111208218.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="sm9/qCh+74CdNMXJ"
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050526.135229.111208218.davem@davemloft.net>
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


--sm9/qCh+74CdNMXJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, May 26, 2005 at 01:52:29PM -0700, David S. Miller wrote:
=20
> > Dave: Please don't apply yet, I want to receive feedback from the
> > netfilter developers first.  I'm just Cc'ing netdev in case somebody
> > wants an intermediate fix to fix the problem.
>=20
> OK.

Do you have any feedback on why or how bh_lock_sock() might be called in
the problem I've described?  I think it has to be a different skb for
the same socket.

Is my general line of thought correct that we shouldn't traverse the
local input path from sysirq context ?

Thanks.

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--sm9/qCh+74CdNMXJ
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFCljh3XaXGVTD0i/8RAmsoAJ9KCcdyOkOZsYLoLgIRG0tKJheAGwCeJ2/U
GMGN0Ik72ChVZKZIiR7igxE=
=y61k
-----END PGP SIGNATURE-----

--sm9/qCh+74CdNMXJ--
