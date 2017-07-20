From: Mark Brown <broonie@kernel.org>
Subject: Re: next-20170720 build: 1 failures 4 warnings (next-20170720)
Date: Thu, 20 Jul 2017 11:06:46 +0100
Message-ID: <20170720100645.de6v27yczsqptcij@sirena.org.uk>
References: <E1dY4uu-0008Od-2S@optimist>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="55ggle5w7kpafvon"
Cc: kernel-build-reports@lists.linaro.org,
        linaro-kernel@lists.linaro.org, linux-next@vger.kernel.org,
        netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
        linux-arm-kernel@lists.infradead.org
To: Felix Fietkau <nbd@openwrt.org>, John Crispin <blogic@openwrt.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <E1dY4uu-0008Od-2S@optimist>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--55ggle5w7kpafvon
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Jul 20, 2017 at 07:26:32AM +0100, Build bot for Mark Brown wrote:

Today's -next fails to build an arm allmodconfig due to:

> 	arm-allmodconfig
> ../drivers/net/ethernet/mediatek/mtk_eth_soc.c:1685:8: error: unknown type name 'irqreturn_t'
> ../drivers/net/ethernet/mediatek/mtk_eth_soc.c:1694:9: error: 'IRQ_HANDLED' undeclared (first use in this function)
> ../drivers/net/ethernet/mediatek/mtk_eth_soc.c:1697:8: error: unknown type name 'irqreturn_t'
> ../drivers/net/ethernet/mediatek/mtk_eth_soc.c:1706:9: error: 'IRQ_HANDLED' undeclared (first use in this function)
> ../drivers/net/ethernet/mediatek/mtk_eth_soc.c:2475:8: error: implicit declaration of function 'devm_request_irq' [-Werror=implicit-function-declaration]

There's no obvious relevant change in the driver, some other header
change will have broken the implicit inclusion it's relying on.  I just
sent a patch.

--55ggle5w7kpafvon
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEreZoqmdXGLWf4p/qJNaLcl1Uh9AFAllwgLUACgkQJNaLcl1U
h9AZlAf+O8dty7xSw1qiRDsxvXSTHxsqSZ9zummTghc7S7ze7UfZOPVrDqtSDzxD
RzlIa0U5TMUl0Jed946+4ei7yAbtDwbmyqC9tB8NBTVj+r1IFenhpKGourEuR+1P
fngr1KK7y4mBWVgGzDwn7qIshsBvJnFa/2SCBTuZQQlN3DNTjtCw52rgSli0y4mC
M2EUxS+xN7WigxsUqZvsAjSVkld1UI32pcj5fr/7OvVS6ELt4wRHyDre1nEgUwWu
GcQeA8T8bhtPoOuOx/jFBZdN7kD8AVtqQlwVmhjvnfYJXeD69RGZhcUIgcMolOo+
CbnMJ6CR7ObpSQ7SuaVnhBtOA6k9Ww==
=3IZg
-----END PGP SIGNATURE-----

--55ggle5w7kpafvon--
