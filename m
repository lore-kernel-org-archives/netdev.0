From: Harald Welte <laforge@netfilter.org>
Subject: Re: ipt_physdev.c alignment problems on parisc64
Date: Sat, 20 Sep 2003 07:50:02 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030920055002.GC8398@sunbeam.de.gnumonks.org>
References: <20030912085606.GC2350@obroa-skai.de.gnumonks.org> <1063371268.1031.96.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="JgQwtEuHJzHdouWu"
Cc: "David S. Miller" <davem@redhat.com>,
        Bart De Schuymer <bdschuym@pandora.be>, acme@conectiva.com.br,
        netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1063371268.1031.96.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--JgQwtEuHJzHdouWu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Sep 12, 2003 at 08:54:29AM -0400, jamal wrote:
> On Fri, 2003-09-12 at 04:56, Harald Welte wrote:
> > On Thu, Sep 11, 2003 at 09:40:46PM -0400, jamal wrote:
> > > Harald,
> > >=20
> > > Could you not resolve all the ifindices of the said ppp+ interfaces
> > > at rule installation time and do an integer compare instead?
> >=20
> > No, this is a different semantic.  Ifindexes change when an interface
> > goes down and comes up again (let's say you have a PPTP tunnel server
> > which terminates a couple of ppp* interfaces).
> >=20
>=20
> If ifindices change for the same device name then that would be a bug.
> The only time they should change is if a) you reboot or b) you unload a
> module after ifconfiged down the device(s) and then reload it later.
> In both cases if you have exactly the same setup, the chances of those
> ifindices changing are very slim.

What about a ppp interface that is deleted because pppd terminated.
Then you start a new pppd that uses the same ppp interface [i.e. ppp12].
Would ifindex still be guaranteed to be the same in that case?

> cheers,
> jamal

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--JgQwtEuHJzHdouWu
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQE/a+qKXaXGVTD0i/8RArmMAKCos2qq2K71Nv3preX0vv0jW7O2RQCdGigx
Hc4OPCRUp2KxYSc2b8vx+uU=
=dYwj
-----END PGP SIGNATURE-----

--JgQwtEuHJzHdouWu--
