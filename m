From: Mark Brown <broonie@kernel.org>
Subject: Re: next-20160929 build: 2 failures 4 warnings (next-20160929)
Date: Thu, 29 Sep 2016 11:47:37 -0700
Message-ID: <20160929184737.ragquwy2tmhxo5bn@sirena.org.uk>
References: <E1bpZhb-0002Oz-OQ@optimist>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="r3uavwzpl3blzqiv"
Cc: kernel-build-reports@lists.linaro.org,
        linaro-kernel@lists.linaro.org, linux-next@vger.kernel.org,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Vishwanath Pai <vpai@akamai.com>, Joshua Hunt <johunt@akamai.com>,
        Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <E1bpZhb-0002Oz-OQ@optimist>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--r3uavwzpl3blzqiv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Sep 29, 2016 at 12:40:35PM +0100, Build bot for Mark Brown wrote:

For the past couple of days -next has been failing to build an ARM
allmodconfig due to:

> 	arm-allmodconfig
> ERROR: "__aeabi_uldivmod" [net/netfilter/xt_hashlimit.ko] undefined!

which appears to be triggered by 11d5f15723c9 (netfilter: xt_hashlimit:
Create revision 2 to support higher pps rates) introducing a division of
a 64 bit number which should be done using do_div().

--r3uavwzpl3blzqiv
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAABCAAGBQJX7WHIAAoJECTWi3JdVIfQ5KUH/339abZCS8frqbj8neJs8s6t
ISnhEV/EcOvwbAsTdNaDs3PVlNTic2DmGInY+mQ/FdQRk8j4n/5sNE3YgoYexFyj
caw49S5dvwnrsMWVGNXd6BRwxtVJY9ae2jWPONaSUCWoiI1ZzEwrYhGgD/nJQFFR
dkw5ohOAKaipfA8AsiF50F/AxERI0w0mYDGdG5sHN+C9B1yu42idA11DU6XtMW76
cYxL+dWkTgIayP/tw3Wl7O6AvUcLojUfwTkDliaizFN45YCeFDoaKvIY8CXM8Yya
iDHvkjK694JHW0iCZMLqtzaMg5HTWhD3PYVhf+NLApYRHLvMtiFihNqYJppfm+g=
=hOF6
-----END PGP SIGNATURE-----

--r3uavwzpl3blzqiv--
