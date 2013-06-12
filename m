From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] e1000e: restore call to pci_clear_master()
Date: Wed, 12 Jun 2013 12:41:11 -0700
Message-ID: <1371066071.2133.40.camel@jtkirshe-mobl>
References: <20130612174747.7449.40767.email-sent-by-dnelson@teal>
	 <51B8C035.9010105@cogentembedded.com> <51B8C393.3090100@redhat.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-xNakEoDnf7vMBx9uK6hG"
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	David Miller <davem@davemloft.net>,
	Konstantin Khlebnikov <khlebnikov@openvz.org>,
	netdev@vger.kernel.org, Bruce Allan <bruce.w.allan@intel.com>
To: Dean Nelson <dnelson@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:33066 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753747Ab3FLTlh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jun 2013 15:41:37 -0400
In-Reply-To: <51B8C393.3090100@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-xNakEoDnf7vMBx9uK6hG
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2013-06-12 at 13:53 -0500, Dean Nelson wrote:
> On 06/12/2013 01:38 PM, Sergei Shtylyov wrote:
> > Hello.
> >
> > On 06/12/2013 09:47 PM, Dean Nelson wrote:
> >
> >> In attempting to resolve a minor merge conflict, commit
> >> e5f2ef7ab4690d2e8faa
> >> accidently dropped a call to pci_clear_master() that was intended to
> >> remain
> >> in place.
> >
> >> Commit 4e0855dff094b0d56d6b replaced a call to pci_disable_device() by
> >> one to
> >
> >     Please specify the summary line in parens for both commmits you're
> > mentioning.
>=20
> Sorry, I'm not understanding fully. Are you asking me to repost the
> patch with the changelog modified, such that each of the commits
> mentioned has their summary statement following, enclosed in parens?
>=20
>=20
> >> pci_clear_master(). And then commit 66148babe728f3e00e13 deleted a
> >> number of
> >> lines starting two lines following that call.
> >
> >> This patch restores the call to pci_clear_master() in __e1000_shutdown=
().
> >
> >> Signed-off-by: Dean Nelson <dnelson@redhat.com>
> >
> > WBR, Sergei
> >
> >
>=20
> Also, I mistyped Jeff Kirsher's email address. It's corrected above.=20
> (Sorry, Jeff.)

No problem, will you be sending a v2 based on Sergei's feedback?  Just
need to know if I add this patch to my queue or wait for v2.

--=-xNakEoDnf7vMBx9uK6hG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJRuM7XAAoJEOVv75VaS+3OExMQAJroxGSIdaGurdt+tP3x/AYk
60LcbTOCVFZeiM2dyuwfBE3WbwAmdI+fLq4kaPYscUYtOIvannwmJ5eQXp3YAZVw
q6tS1vopHogZwO8aszBeNTCEoOgSODusEMgL9ZnFUkvjLa910IimidRlOMWFQCoI
V6ooNrVW5BP7lcAdANPz9dtB8Ik2c31zoN4WE3hoGQqgvO0bOl4vypzetc3Ckxc7
UoqsQVqBhACuXprqoPfmhhbp6HLeB49zLmcKGRKFaxDrM5K6FnFiTOkV8RTElA1p
BrYUEgddkURM2QibInhxn+WL/5EknRJ/t937n8kHQTFsgjcoKzWjsZ7PNzDBxZiX
bcFgfSt0aw7AE9eluZHNTQj8BnYAHIbvVFXXjM/ByfqQOYEymMPH94Zdvh6VVd4i
KCnJTOiKMHM5hVzPvvgQIuAxFSSwh4CWzgW0oi7wNQuk/6nlsvEFZsLNy0Ud5giG
xyTEcTkv3GSWDDQs7C2cQcNzJx/YJevUzaJ83gkBvZSKVx8dMa+qStJ7NiQeJVTN
NjvmE+UG84kAk1Lx7SkrJAQJSOMkbiS2r+OSVsIygfXc/LOjm8kPKVqw1QCBrvKi
oVcEP8Ao3HNYxENAwJzKNFAMM8eFgsXd+qoY7J0zRUfCcHRztoB6KsKOpjHoyfjb
TvROOt9AwwvQXsL3a/B9
=wSB1
-----END PGP SIGNATURE-----

--=-xNakEoDnf7vMBx9uK6hG--
