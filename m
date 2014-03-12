From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCHv2 1/2] bridge: multicast: add sanity check for
 general query destination
Date: Wed, 12 Mar 2014 18:34:30 +0000
Message-ID: <1394649270.23624.37.camel@deadeye.wl.decadent.org.uk>
References: <1394486725-4992-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ND43Wsa0Z+34WmYQEoqE"
Cc: netdev@vger.kernel.org, Florian Westphal <fwestpha@redhat.com>,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Jan Stancek <jstancek@redhat.com>
To: Linus =?ISO-8859-1?Q?L=FCssing?= <linus.luessing@web.de>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1394486725-4992-1-git-send-email-linus.luessing@web.de>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org


--=-ND43Wsa0Z+34WmYQEoqE
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-03-10 at 22:25 +0100, Linus L=C3=BCssing wrote:
> General IGMP and MLD queries are supposed to have the multicast
> link-local all-nodes address as their destination according to RFC2236
> section 9, RFC3376 section 4.1.12/9.1, RFC2710 section 8 and RFC3810
> section 5.1.15.
[...]

That reminds me, shouldn't we also check this in igmp_rcv()?

Ben.

--=20
Ben Hutchings
Any sufficiently advanced bug is indistinguishable from a feature.

--=-ND43Wsa0Z+34WmYQEoqE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUyCotue/yOyVhhEJAQrdig/8CVIRl1VyXYVa7PtHzg18ylSpt1ABBSJt
dTNXvfr8suM1r6HIPW8+OtpRz4kCFhxKbGtdpwN19BNxnAK5IreNtB3fqSVpbSA5
CO6bp2GW+jmUCwSVPDqVwOys3yl3wWO7FRfFXxiBB5rK6SeXsRf2pApdYP0ZxTBJ
hATVKTsVNhlpsJeaqfwi5ClyWpSOvgSg8nZXzDI8nkPbrg+h0ZSwvZKePl9xNCBb
l5m7qgoWf8C1be5C2XMA3+KsypYdPtPvPEdEYcfPOxCgk6tIkeqnJgn7qazg5p1Q
ats/ISFfZc0cpju2s/PdxF5J0KWUZ1vX1WChh1bukkjp+zvka03mz5mhQvtxIFx6
Ha7vz1wtegY4P1gjlrgmY/yPLME+nDnHKKq49+zsOzblTU641+0KjaUb8wSEmC+m
45seNczCHyZie3Qua/GIKr0KObu+mPB5Ji6+OitkHtoaGIPfG7UC+ee69YM2mzH3
KuOqi5PQd7lFLvilh0L3SqnWg3Z0HW2H44mHtbqTm89mbjhREsOOKT+O/HbQZ6ji
GFYyMPypWlELq4PqfNNtbFDpw62jE77NVQ1dZ5UFEIjERqdLJGyUwWfhGfOIOkTx
oZ8IimWG6NqRviPaj/kKcDjtIHASjaI4GF1wMfJwO0LedUK0ilqdd2YQo3aXir88
oWUx+dE6Ogs=
=9o4B
-----END PGP SIGNATURE-----

--=-ND43Wsa0Z+34WmYQEoqE--
