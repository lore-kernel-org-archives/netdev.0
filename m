From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: Re: GUPD (Grand Unified Prism54 Driver) Open
	discussion
Date: Tue, 15 Jun 2004 20:11:11 -0400
Sender: prism54-devel-bounces@prism54.org
Message-ID: <20040616001111.GK6253@ruslug.rutgers.edu>
References: <5.1.0.14.2.20040615143603.02a40b48@pop.t-online.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1272162830=="
Cc: Netdev <netdev@oss.sgi.com>, prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: Margit Schubert-While <margitsw@t-online.de>
In-Reply-To: <5.1.0.14.2.20040615143603.02a40b48@pop.t-online.de>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Mime-version: 1.0
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


--===============1272162830==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="bKyqfOwhbdpXa4YI"
Content-Disposition: inline


--bKyqfOwhbdpXa4YI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jun 15, 2004 at 09:17:48PM +0200, Margit Schubert-While wrote:
> As an experiment, I have just tried merging all source code for a
> GUPD (Grand Unified Prism54 Driver)  :-)
> prism54.h - 1063 lines
> prism54.c - 5583 lines
> With everything defined static (data and functions), it works and
> saves a chunk of generated code.
>=20
> Is this something we should be looking at ?
>=20
> Some points :
> With this setup, we can move the driver up into net/wireless.
> We get rid of the horrible prism include dependencies.
> (All structures/defs are available to all routines)
> Everything gets defined static allowing the compiler to produce
> compact code.  This, though, means that kernel stack traces are
> less informative. (But, of course, we don't get oops'es in prism54
> do we ? :-) )
>=20
> OK Discuss.

I like the idea, I think we should just time the change appropriately to
alllow current work out there to get included / branched in.

---
What's left / being worked on (near future)?=20

* WPA - PSK - I'm working on this, hope to have a patch this week for cvs t=
esting.

* WDS - Umm someone on the list had mentioned they had used WDS
  successfully and had some patches (?) Are you still alive? Are you
  still working on this?

* ethtool support - Basic ethtool support is easy althought this can
  wait

* Move verbose/debug printing to use netif_msg instead of our nasty ifdefs.
  No one is working on this yet though so it can wait.

---

Anyone else working on anything for prism54 and would like us to wait
for you before merging all into the proposed GUPD?

Anyone disagree with this approach? Comments?

PS: please CC netdev

	Luis

--=20
GnuPG Key fingerprint =3D 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E

--bKyqfOwhbdpXa4YI
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAz5Afat1JN+IKUl4RAsSHAJsG/ZbrUzDUkEEF2FibxBnRLuyFgwCgocDL
FKTVO+DTbGmVfVD26OgBM8w=
=Gx5I
-----END PGP SIGNATURE-----

--bKyqfOwhbdpXa4YI--

--===============1272162830==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--===============1272162830==--
