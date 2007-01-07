From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH/RFC 00/10] Transparent proxying patches version 4
Date: Sun, 7 Jan 2007 15:11:34 +0100
Message-ID: <20070107141134.GA13543@prithivi.gnumonks.org>
References: <20070103163357.14635.37754.stgit@nienna.balabit>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="zhXaljGHf11kAtnf"
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: KOVACS Krisztian <hidden@balabit.hu>
Content-Disposition: inline
In-Reply-To: <20070103163357.14635.37754.stgit@nienna.balabit>
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


--zhXaljGHf11kAtnf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Krisztian!

On Wed, Jan 03, 2007 at 05:33:57PM +0100, KOVACS Krisztian wrote:
> So instead of using NAT to dynamically redirect traffic to local
> addresses, we now rely on "native" non-locally-bound sockets and do
> early socket lookups for inbound IPv4 packets.=20

It's good to see a solid implementation of this 'old idea'. =20

Just as a quick historical note to netdev:  This is the way how the
netfilter project  advised the balabit guys to implement fully
transparent proxy support, after having seen the complexity of the old
nat-based TPROXY patches.

So I personally support this patchset and vote for it to be included
(with whatever modifications netdev deems apropriate)

It might be that there now is the experimental netchannels system which
might provide an even better way for transparent proxy support.

However, ever since ip_tables was merged in the 2.3.x days, we have
lacked good support for transparent proxies.  Now that the first
incarnation of the NAT based TPROXY patch for 2.4.x had to be developed
and maintained out-of-tree for many years, I definitely think it's
better to merge the new, way less intrusive, patchset. =20

Some interested party can work on a netchannels implementation later on,
but that's the next generation...

Cheers,
--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--zhXaljGHf11kAtnf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFFoP+WXaXGVTD0i/8RAklqAKCYnOqaXDEH+yEy7SpzIbzsVzV2CgCeLxf8
kAs/DJdHhQpBv6AmONPavCA=
=gUEP
-----END PGP SIGNATURE-----

--zhXaljGHf11kAtnf--
