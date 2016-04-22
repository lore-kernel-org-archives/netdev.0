From: Mark Brown <broonie@kernel.org>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Fri, 22 Apr 2016 10:20:17 +0100
Message-ID: <20160422092017.GY3217@sirena.org.uk>
References: <20160413175028.5d3a4cf2@canb.auug.org.au>
 <20160413.111513.295841881765244758.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="OF9salbnfkEgqvaK"
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	mark.d.rustad@intel.com, jeffrey.t.kirsher@intel.com,
	andrewx.bowers@intel.com, kernel-build-reports@lists.linaro.org,
	linaro-kernel@lists.linaro.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160413.111513.295841881765244758.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--OF9salbnfkEgqvaK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Apr 13, 2016 at 11:15:13AM -0400, David Miller wrote:
> From: Stephen Rothwell <sfr@canb.auug.org.au>

> > After merging the net-next tree, today's linux-next build (arm
> > allmodconfig) failed like thisi (this has actually been failing for a
> > few days, now):

> > ERROR: "__bad_udelay" [drivers/net/ethernet/intel/ixgbe/ixgbe.ko] undefined!

> > Caused by commit

> >   49425dfc7451 ("ixgbe: Add support for x550em_a 10G MAC type")

> > arm only allows udelay()s up to 2 milliseconds.  This commit
> > adds a 5 ms udelay in ixgbe_acquire_swfw_sync_x550em_a() in
> > drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c.

> Jeff, please have your folks look into this.  Probably just a simple
> conversion to mdelay().

This is still present, it's been breaking ARM allmodconfig builds for
about two weeks now.

--OF9salbnfkEgqvaK
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJXGezPAAoJECTWi3JdVIfQwVoH/1PObZeqwTdPwXtexQ9WqU55
CcHzBrbx1J7ZAJyhrtxZ9qgtp3T93LogFa17sPhEGQdSScN51MKyN8QRupTlIp5N
AgaTBe3TtOwpiU2CO8rTpom5cGCa1i1oVwOa4r6ez07yk7oNs0vRe2gYrwXiHuek
hAICgg0mITwqRx/uiEFiW4gb2CByRsCg8oUkDUhzvKsMzQn/S4PRc3e9cQtyKqcc
K7AoRnDvrab5dBvG5pCk0K5fpGYAvDoTuM7MjZX0FljvZ0oTtWN0kUQKkX39lJn/
GZfuktFd1S8R64OlUYthq71slpD0NCwYWBZfmL2moGKNBb95y+kwZQzhHWWBsrY=
=zZ0f
-----END PGP SIGNATURE-----

--OF9salbnfkEgqvaK--
