From: "Michael H. Warfield" <mhw@wittsend.com>
Subject: Re: IPv4 tunneled over IPv6-IPsec?
Date: Mon, 28 Mar 2005 15:06:31 -0500
Message-ID: <1112040391.17216.44.camel@localhost.localdomain>
References: <E1DFUeO-0001IS-00@gondolin.me.apana.org.au>
	 <13B368C239630E8F2BA18AF3@[192.168.17.4]>
Reply-To: mhw@wittsend.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-rFZfKiCqyizA8fK027Kb"
Cc: mhw@wittsend.com, netdev@oss.sgi.com,
        Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-bounce@oss.sgi.com>
To: Peter Bieringer <pb@bieringer.de>
In-Reply-To: <13B368C239630E8F2BA18AF3@[192.168.17.4]>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-rFZfKiCqyizA8fK027Kb
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hey Peter!

On Sun, 2005-03-27 at 14:47 +0200, Peter Bieringer wrote:
> Hi Herbert,

> thank you for quick reply.

> --On Sonntag, 27. M=E4rz 2005 20:05 +1000 Herbert Xu=20
> <herbert@gondor.apana.org.au> wrote:

> > Peter Bieringer <pb@bieringer.de> wrote:
> >>
> >> I retry to play tunneling IPv4 over IPv6-IPsec. Afair it is still not
> >> working (support is missing in 2.6.x kernel), but for startup, I have
> >> already a patch for ipsec.conf parsing (pluto already has an option to
> >> do  this):
> >
> > The native IPsec stack doesn't support IPv4 over IPv6 or IPv6 over
> > IPv4 SAs.  It won't be able to do so unless major surgery is done
> > to the IPsec and IP stack.

> Hmm, looks like more a long term issue :-(

> So another question: what is the status of tunneling IPv4 over IPv6 witho=
ut=20
> IPsec e.g. using GRE or special native tunneling? Similar issue? I digged=
 a=20
> little bit around in GRE code and found some IPv6 references but no hints=
=20
> whether it can be used for that also.

	You might want to check out the DSTM package here:

	<http://www.ipv6.rennes.enst-bretagne.fr/dstm/>

	That includes a tsp server as well as a 4over6 driver.  Jim Bound is
the author/editor of record for the IETF draft on DSTM.

	<http://www.ietf.org/internet-drafts/draft-bound-dstm-exp-02.txt>

	I've had it spun up on some Linux systems in the past for testing
purposes.  Unfortunately, it does not seem to be updated to build under
the 2.6 kernels.  :-(

> BTW: the reason why I'm looking for such support is the need to connect=20
> some "legacy" IPv4 islands over IPv6.

> Regards,
> 	Peter

	Mike
--=20
 Michael H. Warfield    |  (770) 985-6132   |  mhw@WittsEnd.com =20
  /\/\|=3Dmhw=3D|\/\/       |  (678) 463-0932   |  http://www.wittsend.com/=
mhw/
  NIC whois:  MHW9      |  An optimist believes we live in the best of all
 PGP Key: 0xDF1DD471    |  possible worlds.  A pessimist is sure of it!

--=-rFZfKiCqyizA8fK027Kb
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iQCVAwUAQkhjx+HJS0bfHdRxAQK03wQAvabi9ngBGLEubKvE77OZ93+YGGJuP+1K
z9W1PnQix/ziUpL6KtgPG00JqM+ongwdnhrVcUzCX52NpNwSIFtUiUjU//c2LnLp
+j46XaNDdbz4xvYYY9ltcwaFQx/cRTU7e2u//eAI9HVhAHl8jesLrKzHpYNE2dGZ
I1zerFbjWlo=
=keWg
-----END PGP SIGNATURE-----

--=-rFZfKiCqyizA8fK027Kb--
