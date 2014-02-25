From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [RFC v2 2/4] net: enables interface option to skip IP
Date: Tue, 25 Feb 2014 00:02:00 +0000
Message-ID: <1393286520.6823.123.camel@deadeye.wl.decadent.org.uk>
References: <1392857777.22693.14.camel@dcbw.local>
	 <CAB=NE6Xvqcdje5OSxjzTRa3wv-vZHr+MJHY86ZCfFXU2Lpzi8Q@mail.gmail.com>
	 <1393266120.8041.19.camel@dcbw.local>
	 <20140224.180426.411052665068255886.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-q/kcLpXQr5co7KvsyRKe"
Cc: dcbw@redhat.com, mcgrof@do-not-panic.com, zoltan.kiss@citrix.com,
	netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140224.180426.411052665068255886.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-q/kcLpXQr5co7KvsyRKe
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-02-24 at 18:04 -0500, David Miller wrote:
> From: Dan Williams <dcbw@redhat.com>
> Date: Mon, 24 Feb 2014 12:22:00 -0600
>=20
> > In the future I expect more people will want to disable IPv4 as
> > they move to IPv6.
>=20
> I definitely don't.
>=20
> I've been lightly following this conversation and I have to say
> a few things.
>=20
> disable_ipv6 was added because people wanted to make sure their
> machines didn't generate any ipv6 traffic because "ipv6 is not
> mature", "we don't have our firewalls configured to handle that
> kind of traffic" etc.
>=20
> None of these things apply to ipv4.
>=20
> And if you think people will go to ipv6 only, you are dreaming.
>
> Name a provider of a major web sitewho will go to strictly only
> providing an ipv6 facing site?
>
> Only an idiot who wanted to lose significiant nunbers of page views
> and traffic would do that,

That's obviously true for public-facing servers, but that doesn't mean
it's not useful to anyone.

> so ipv4 based connectivity will be universally necessary forever.

You can run an internal network, or access network, as v6-only with
NAT64 and DNS64 at the border.  I believe some mobile networks are doing
this; it was also done on the main FOSDEM wireless network this year.

Ben.

> I think disable_ipv4 is absolutely a non-starter.


--=20
Ben Hutchings
Beware of bugs in the above code;
I have only proved it correct, not tried it. - Donald Knuth

--=-q/kcLpXQr5co7KvsyRKe
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUwvdeOe/yOyVhhEJAQplZA//QAOw2FY8BWwaK/c447vv7/VYuzUNjLOL
Ea5KRTemhsIXOddkKnNggp/S3gyTEN4xMGGf4+/DvdhRnRpWT/4os65OU/yR2lD6
sUUhvP2ALHFNWxOu/k8eAB+P5nc92ulBXy1kGHnIoPZxC7PEj8O5zNHPQvyhTPBM
rrUGp3XkZ704uf3EA8pA2NE/o4e8f8uQC0uq97J0vfIZYSZ4opFT9wdsU92Q0UR5
1Z3E2n1f3ZRD0n5+CKV7pNPvuD52HOhknai6Rcg86b4/YDd+4mgSYjA68CJTAyeQ
EzlPnT6LyP119eylvkfpwvkO0YBfJJ1UBlBsNPPn+ki1CcZ+X4aomcvo9UxTVYye
X8N1SJzTm4h53fFRDoLR5WRBL67rGezSWz/ZUfxy92O8PQUTAjPNUHGnuwSdh2A8
p20dt8NlQAlbYMwwklbNQtgEuH+mod1ntljx6MJOA4RELN3mQxgBTAfHBHWiNfS6
BJYUUcDWjygc9vLIhYOx1ioJArNSnMw/hjP0uD/jvigrtfdD6DYjQf8XBGwvQqyr
ziKk7pj8CfhLdo1YwS8EFmX6Mh3Dhf8xE+2+O7L+dyXLCItjOeg/xE3ZrXudb0qB
9fMGr5W3o2Ot6ICvKxAY2r3N87N9s1gqgoK2kKx/tB6RA0DkN1YdnLvsCEfnhnuv
KLuqk8+mKes=
=iTMC
-----END PGP SIGNATURE-----

--=-q/kcLpXQr5co7KvsyRKe--
