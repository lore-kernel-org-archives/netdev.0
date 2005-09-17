From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: Route cache performance
Date: Sat, 17 Sep 2005 11:04:09 +0200
Message-ID: <1126947850.4549.11.camel@localhost.localdomain>
References: <20050825200543.GA6612@yakov.inr.ac.ru>
	 <20050825212211.GA23384@netnation.com>
	 <20050826115520.GA12351@yakov.inr.ac.ru>
	 <17167.29239.469711.847951@robur.slu.se>
	 <20050906235700.GA31820@netnation.com>
	 <17182.64751.340488.996748@robur.slu.se>
	 <20050907162854.GB24735@netnation.com>
	 <20050907195911.GA8382@yakov.inr.ac.ru>
	 <20050913221448.GD15704@netnation.com>
	 <17191.55685.861191.831981@robur.slu.se>
	 <20050917002823.GB19112@netnation.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-kW9ddZExY4QUTFvf/+VF"
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Eric Dumazet <dada1@cosmosbay.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Simon Kirby <sim@netnation.com>
In-Reply-To: <20050917002823.GB19112@netnation.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-kW9ddZExY4QUTFvf/+VF
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2005-09-16 at 17:28 -0700, Simon Kirby wrote:

> I got stuck in some mud again, but I was able to run a small oprofile.
>=20
> nf_iterate was near the top even though the firewall was empty, so I
> changed CONFIG_IP_NF_IPTABLES=3Dy to CONFIG_IP_NF_IPTABLES=3Dm (and didn'=
t
> load it).  Throughput went up from 173 Mbps to 232 Mbps...yikes.=20
> Conntrack was never compiled.  I'll do some more profiling when I get
> a chance...

Yes, it's bloody slow even without any rules loaded at the moment, it's
on my todo list...

If you want even less overhead then don't even select CONFIG_NETFILTER,
that way you avoid compiling in the netfilter hooks completely.

--=20
/Martin

--=-kW9ddZExY4QUTFvf/+VF
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQBDK9wJWm2vlfa207ERArTcAJ9tvSLM0aeQEJMqQnOmGcFIYTHoeQCgk98y
P5zTc3hcYsjAqfV1HE2ux/0=
=OQEB
-----END PGP SIGNATURE-----

--=-kW9ddZExY4QUTFvf/+VF--
