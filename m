From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: Re: Re: TxDescriptors -> 1024 default. Please not for every NIC!
Date: Thu, 20 May 2004 10:11:11 -0400
Sender: prism54-devel-admin@prism54.org
Message-ID: <20040520141111.GR13898@ruslug.rutgers.edu>
References: <OF72607111.CD0234C8-ON85256DA1.0068861B-86256DA1.0068FF60@us.ibm.com> <Pine.LNX.4.58.0405151354220.9894@fcat> <Pine.LNX.4.58.0405190256010.30653@fcat> <20040519102700.GA16465@ee.oulu.fi>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ccJhwVfaC+fHwTsl"
Cc: Marc Herbert <marc.herbert@free.fr>, netdev@oss.sgi.com,
	prism54-devel@prism54.org, Jean Tourrilhes <jt@hpl.hp.com>
Return-path: <prism54-devel-admin@prism54.org>
To: Pekka Pietikainen <pp@ee.oulu.fi>
Content-Disposition: inline
In-Reply-To: <20040519102700.GA16465@ee.oulu.fi>
Errors-To: prism54-devel-admin@prism54.org
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Post: <mailto:prism54-devel@prism54.org>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel/>
List-Id: netdev.vger.kernel.org


--ccJhwVfaC+fHwTsl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, May 19, 2004 at 01:27:00PM +0300, Pekka Pietikainen wrote:
> On Wed, May 19, 2004 at 11:30:28AM +0200, Marc Herbert wrote:
> > - Me argues that we all lived happy for ages with this default
> >   setting of 100?packets @?100?Mb/s (and lived approximately happy @
> >   10 Mb/s), but we'll soon see doom and gloom with this new and
> >   brutal change to 1000?packets for all this _legacy_ 10-100 Mb/s
> >   hardware. e1000 data only is not enough to justify this radical
> >   shift.
> >=20
> > If you are convinced by _both_ items above, then the patch below
> > content _both_, and we're done.
> >=20
> > If you are not, then... wait for further discussion, including answers
> > to latest Ricardo's post.
>
> Not to mention that not all modern hardware is gigabit, current
> 2.6 seems to be setting txqueuelen of 1000 for 802.11 devices too (at lea=
st
> my prism54), which might be causing major problems for me.

Considering 802.11b's peak is at 11Mbit and standard 802.11g is at 54Mbit
(some manufacturers are using two channels and getting 108Mbit now) I'd
think we should stick at 100, as the patch proposes. Jean?

	Luis

--=20
GnuPG Key fingerprint =3D 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E

--ccJhwVfaC+fHwTsl
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFArLx/at1JN+IKUl4RAnt0AKCuiVsLnvq9Wpn7AxPgfmsWitHcggCdGNFY
y973K281JSw3DGUFavnhq0U=
=PCWw
-----END PGP SIGNATURE-----

--ccJhwVfaC+fHwTsl--
