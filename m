From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH] Reduce netfilter memory use on MP systems
Date: Mon, 7 Feb 2005 19:31:25 +0100
Message-ID: <20050207183125.GJ10011@obroa-skai.de.gnumonks.org>
References: <20050204140900.GD2518@wotan.suse.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="wjoFZxbW4tu+iR6v"
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <20050204140900.GD2518@wotan.suse.de>
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


--wjoFZxbW4tu+iR6v
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Feb 04, 2005 at 03:09:00PM +0100, Andi Kleen wrote:
>=20
> On kernels compiled with a big NR_CPUS netfilter rules would=20
> eat a lot of memory because all counters would be duplicated
> for all NR_CPUs CPUs.  With NR_CPUS=3D256 this would add up
> to many MBs of memory.

Thanks, Andi.  I think the NR_CPUS is actually a remnescant of 2.3.x
times when we didn't have num_possible_cpus() yet.

Also wrt. your vmalloc issues, I think there are floating around some
patches which replace our vmalloc use by __get_free_pages() anyway.

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--wjoFZxbW4tu+iR6v
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFCB7P9XaXGVTD0i/8RAmIqAJwJtMIpX7En5Aviun9GlUNlYgwlEACfW9aJ
imO65JN9lU62h80CgsPfO2s=
=V8jP
-----END PGP SIGNATURE-----

--wjoFZxbW4tu+iR6v--
