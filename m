From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH] [RFT] ip_tables NUMA optimization
Date: Sat, 19 Nov 2005 09:45:47 +0100
Message-ID: <20051119084547.GC20775@sunbeam.de.gnumonks.org>
References: <20051117144328.GG14201@sunbeam.de.gnumonks.org>
	<437CA009.4020006@cosmosbay.com>
	<20051118.160043.119281166.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="7DO5AaGCk89r4vaK"
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	dada1@cosmosbay.com
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20051118.160043.119281166.davem@davemloft.net>
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


--7DO5AaGCk89r4vaK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Nov 18, 2005 at 04:00:43PM -0800, David S. Miller wrote:
=20
> > It should probably use vfree() like :
> >=20
> >  > +	for_each_cpu(cpu) {
> >  > +		if (info->size <=3D PAGE_SIZE)
> >  > +			kfree(info->entries[cpu]);
> >  > +		else
> >  > +			vfree(info->entries[cpu]);
> >  > +	}
>=20
> I've put the patch into the net-2.6.16 tree with the obvious
> fix Eric points out.

thanks!

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--7DO5AaGCk89r4vaK
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQFDfuY7XaXGVTD0i/8RAkleAJ4ypKMWb95I65mZmuaXE7WuovSNhACeMQOP
SJJSmOzVARkjUtH1BuyfaJ8=
=tOKf
-----END PGP SIGNATURE-----

--7DO5AaGCk89r4vaK--
