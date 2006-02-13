From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH] [NETFILTER] nf_conntrack: clean up to reduce size of
	'struct nf_conn'
Date: Mon, 13 Feb 2006 09:17:58 +0100
Message-ID: <20060213081758.GL4601@sunbeam.de.gnumonks.org>
References: <20060212175622.GG4601@sunbeam.de.gnumonks.org>
	<200602130132.k1D1WoYA003717@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="KjSGHOmKKB2VUiQn"
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	davem@davemloft.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>
Content-Disposition: inline
In-Reply-To: <200602130132.k1D1WoYA003717@toshiba.co.jp>
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


--KjSGHOmKKB2VUiQn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Feb 13, 2006 at 10:32:49AM +0900, Yasuyuki KOZAKAI wrote:
>=20
> Hi, Harald,
>=20
> From: Harald Welte <laforge@gnumonks.org>
> Date: Sun, 12 Feb 2006 18:56:22 +0100
>=20
> > [NETFILTER] nf_conntrack: clean up to reduce size of 'struct nf_conn'
> >=20
> > This patch moves all helper related data fields of 'struct nf_conn' int=
o a
> > separate structure 'struct nf_conn_help'.  This new structure is only
> > present in conntrack entries for which we actually have a helper loaded.
> >=20
> > Also, this patch cleans up the nf_conntrack 'features' mechanism to
> > resemble what the original idea was:  Just glue the feature-specific
> > data structures at the end of 'struct nf_conn', and explicitly re-calcu=
late
> > the pointer to it when needed rather than keeping pointers around.
> >=20
> > Saves 20 bytes per conntrack on my x86_64 box. A non-helped conntrack is
> > 276 bytes. We still need to save another 20 bytes in order to fit into =
to
> > target of 256bytes.
> >=20
> > Signed-off-by: Harald Welte <laforge@netfilter.org>
>=20
> This patch seems not to include fixes I pointed out and you said "fixed".
> Please confirm if you really sent the intended one.

oops, thanks for checking.  Dave: Please hold, I sent an old version.
You'll get a new one ASAP.

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--KjSGHOmKKB2VUiQn
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQFD8EC2XaXGVTD0i/8RAqnkAJ9m/Nob52YxxPWcqbn4SRJjjAw4NQCeIoEG
JCvGD3O+Q/PGDs7zbBarlQY=
=cc51
-----END PGP SIGNATURE-----

--KjSGHOmKKB2VUiQn--
