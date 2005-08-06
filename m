From: Harald Welte <laforge@gnumonks.org>
Subject: Re: atheros driver - desc
Date: Sat, 6 Aug 2005 23:45:44 +0200
Message-ID: <20050806214544.GA4594@rama.de.gnumonks.org>
References: <42F2D523.9020702@gmail.com> <8764uig7nm.fsf@litku.valo.iki.fi>
	<20050806205308.GA25208@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0117719485=="
Cc: Kalle Valo <Kalle.Valo@iki.fi>, kernel-mentors@selenic.com,
        netdev <netdev@vger.kernel.org>
Return-path: <kernel-mentors-bounces@selenic.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20050806205308.GA25208@havoc.gtf.org>
List-Unsubscribe: <http://selenic.com/mailman/listinfo/kernel-mentors>,
	<mailto:kernel-mentors-request@selenic.com?subject=unsubscribe>
List-Archive: <http://www.selenic.com/pipermail/kernel-mentors>
List-Post: <mailto:kernel-mentors@selenic.com>
List-Help: <mailto:kernel-mentors-request@selenic.com?subject=help>
List-Subscribe: <http://selenic.com/mailman/listinfo/kernel-mentors>,
	<mailto:kernel-mentors-request@selenic.com?subject=subscribe>
Mime-version: 1.0
Sender: kernel-mentors-bounces@selenic.com
Errors-To: kernel-mentors-bounces@selenic.com
List-Id: netdev.vger.kernel.org


--===============0117719485==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="cNdxnHkX5QqsyA0e"
Content-Disposition: inline


--cNdxnHkX5QqsyA0e
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Aug 06, 2005 at 04:53:08PM -0400, Jeff Garzik wrote:
>=20
> It is certainly preferred that someone write a document describing the
> hardware, and then a totally separate team write the driver, based on
> that document.

No question to that.  However, I think it largely depends on _where_ the
actual re-engineering is done.

Here in Germany, the copyright law is  perfectly fine with reverse
engineering, as long as you don't actually decompile.  The intent of the
law is to prevent you from gaining access to the source code (which
isn't possible in heavily optimized compiled languages anyway).  There
is no problem with trying to learn how the program works and what it
actually does.

All over the EU, the EUCD states that you are explicitly allowed to do
_any_ kind of re-engineering for the purpose of compatibility /
interoperability (and you want to make that card interoperable with
the linux OS...)  All you need to do is to ask the copyright holder for
the required documentation. If they don't produce it within a given
timeframe (IIRC one month), then you can go and start re-engineering
without the approval of the copyright holders.

Also, lots of the low-level driver routines are not copyrightable works
anyway.  If you need to set up the registers of a device in a certain
sequence in order to get it work, then there is no other way of doing
so.  Therefore the corresponding source code is not the result of a
creative process of the author.

I don't want to turn this list into a list of legal discussion, but
since I'm heavily dealing with exactly those issues during my
gpl-violations.org efforts, I thought I share some of the facts.

So in general, at least if you're doing that kind of work within the EU,
I wouldn't be worried all that much.

--=20
- Harald Welte <laforge@gnumonks.org>          	        http://gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)

--cNdxnHkX5QqsyA0e
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC9S+IXaXGVTD0i/8RAhn/AKCpUokSFrg2wvslp3sEVwF/kGmGJACfQUy4
38ElU24XKik2dI9q4Or00/M=
=9O8n
-----END PGP SIGNATURE-----

--cNdxnHkX5QqsyA0e--

--===============0117719485==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Kernel-mentors mailing list
Kernel-mentors@selenic.com
http://selenic.com/mailman/listinfo/kernel-mentors

--===============0117719485==--
