From: Harald Welte <laforge@netfilter.org>
Subject: Re: [NETFILTER] NAT sequence adjustment: Save eight bytes per
	conntrack
Date: Tue, 31 Jan 2006 10:26:24 +0100
Message-ID: <20060131092624.GM4603@sunbeam.de.gnumonks.org>
References: <20060130232209.GG4603@sunbeam.de.gnumonks.org>
	<1138697452.5005.9.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="v8j16QASIjel+GfP"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Balazs Scheidler <bazsi@balabit.hu>
Content-Disposition: inline
In-Reply-To: <1138697452.5005.9.camel@bzorp.balabit>
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


--v8j16QASIjel+GfP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jan 31, 2006 at 09:50:52AM +0100, Balazs Scheidler wrote:

> > -	int32_t offset_before, offset_after;
> > +	int16_t offset_before, offset_after;
>=20
> Am I missing something or is it only 4 bytes?

I knew someone would ask that question ;)

we have that structure as part of an IP_CT_DIR_MAX array, therefore it's
twice in every conntrack, and thus we save 8 bytes ;)

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--v8j16QASIjel+GfP
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQFD3y1AXaXGVTD0i/8RAhGcAJ9chUK+6qElHaeENPaLCRlwKuxngACeP6Ey
gxYErOrf5IKZT9pcNAXF+0s=
=repF
-----END PGP SIGNATURE-----

--v8j16QASIjel+GfP--
