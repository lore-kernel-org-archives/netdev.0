From: Wolfram Sang <wsa@the-dreams.de>
Subject: Re: [PATCH v2 2/3] net: can: c_can: Add syscon/regmap RAMINIT
 mechanism
Date: Tue, 30 Sep 2014 16:19:10 +0200
Message-ID: <20140930141909.GP1325@katana>
References: <1410273070-22485-1-git-send-email-rogerq@ti.com>
 <1410273070-22485-3-git-send-email-rogerq@ti.com>
 <20140930132650.GN1325@katana>
 <542AB137.30507@ti.com>
 <20140930135226.GO1325@katana>
 <542AB6E9.9000907@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="TRkqPRiqIDKgfg/F"
Cc: wg@grandegger.com, mkl@pengutronix.de, tony@atomide.com,
	tglx@linutronix.de, mugunthanvnm@ti.com, george.cherian@ti.com,
	balbi@ti.com, nsekhar@ti.com, nm@ti.com,
	sergei.shtylyov@cogentembedded.com, linux-omap@vger.kernel.org,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: Roger Quadros <rogerq@ti.com>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <542AB6E9.9000907@ti.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--TRkqPRiqIDKgfg/F
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


> As just TI is using this out of band RAMINIT mechanism, should it be "ti,syscon" or just "syscon"?

Yes, only TI uses this out-of-band RAMINIT (currently, at least). So, we
need an (optional) way to describe that. However, accessing syscon
registers in general is not TI specific and a generic way to do this
should be used. Which looks to me like the "syscon" property to allow
access to the register. Still, we should ask DT maintainers about it,
maybe they prefer a more precise property like "syscon-raminit" to allow
for further syscon extensions later or something...


--TRkqPRiqIDKgfg/F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUKrvdAAoJEBQN5MwUoCm2020P/RZ1iJ7JPO9vy7PQQF/rYAMj
FEgjCcQw/yLQXKf7aUnZYKJKqJt2WiynhFRtflJT++iZwC15GOkW3m5pimBwPc5S
MyWaw5za4P04WNqXriAm6R83HdxVUcgfLeq34uyEgovwBuECxOowzqInZSyH9aWN
UdBSeinaLnIQ/hArxLz5wEUz2M71Ucest/0VFZojWKsaB3Fphr3+vAeFa8Z1uhoa
Yz6bDiQxTaWcjmHJuvBrg/mdeYhIiVq0HmU2aK8RQgNnJ0hNpZZUD0zC0EnJPK92
+wq2c7lxLyDJTGvlf4B+Xu8rofFKOk7RfypIYScWcqxIzsGkFh+JYMNYaZKYHuxJ
QkGH0C8GxNAW+brMOCpC5IcXnnvKlFjvAgZ1zSvHxaED3O0Eo32bAwZUpjyejiaC
34uCslxD9oklK0H5CFB4bWmT/7q2IyJLedNBkz39rspBminWPAylPamIRdKSUGm2
zsxOrOMhTQWLuEAceS0mkuVqRuSchTVgPeeXoQL8Zjj59p1hweAEX9+GASt12hQ3
EOpr73ILC3BHkWLx0YLi+TwyD3Tunh0Wz2uA2bWRyJ88tmSaVTvswL0p8XarNX/N
Rcup9fwgJGhKhRFmRa7LYFeXiuub9hxae7Rwps7vZhBge+JzfsJNP8CMm05wF0Ib
TvloFTKDgcoLszWbuy46
=9OuR
-----END PGP SIGNATURE-----

--TRkqPRiqIDKgfg/F--
