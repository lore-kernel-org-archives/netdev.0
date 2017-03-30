From: Thierry Reding <treding@nvidia.com>
Subject: Re: [PATCH] [net-next] stmmac: use netif_set_real_num_{rx,tx}_queues
Date: Thu, 30 Mar 2017 16:34:36 +0200
Message-ID: <20170330143435.GA28098@ulmo.ba.sec>
References: <20170328094856.3457886-1-arnd@arndb.de>
 <20170328.180105.1996071259325891752.davem@davemloft.net>
 <20170330074536.GA4814@Red>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="4Ckj6UjgE2iN1+kY"
Cc: David Miller <davem@davemloft.net>, <arnd@arndb.de>,
        <peppe.cavallaro@st.com>, <alexandre.torgue@st.com>,
        <Joao.Pinto@synopsys.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170330074536.GA4814@Red>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--4Ckj6UjgE2iN1+kY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Mar 30, 2017 at 09:45:36AM +0200, Corentin Labbe wrote:
> On Tue, Mar 28, 2017 at 06:01:05PM -0700, David Miller wrote:
> > From: Arnd Bergmann <arnd@arndb.de>
> > Date: Tue, 28 Mar 2017 11:48:21 +0200
> >=20
> > > A driver must not access the two fields directly but should instead u=
se
> > > the helper functions to set the values and keep a consistent internal
> > > state:
> > >=20
> > > ethernet/stmicro/stmmac/stmmac_main.c: In function 'stmmac_dvr_probe':
> > > ethernet/stmicro/stmmac/stmmac_main.c:4083:8: error: 'struct net_devi=
ce' has no member named 'real_num_rx_queues'; did you mean 'real_num_tx_que=
ues'?
> > >=20
> > > Fixes: a8f5102af2a7 ("net: stmmac: TX and RX queue priority configura=
tion")
> > > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> >=20
> > Applied.
>=20
> This break my revert patch. (since it patch ("net: stmmac: enable multipl=
e buffers").
> Since dwmac-sunxi is still broken, what can I do ? send two revert patch =
? or adapt the reverting patch.

Have you tried if the kcalloc() patch I sent on Tuesday fixes things the
issues introduced by the multiple buffers patch? Niklas reported that it
restores functionality on his setup.

If it makes things work for you as well, we could maybe avoid the revert
altogether.

You can find the patch here:

	https://patchwork.ozlabs.org/patch/744286/

Thierry

--4Ckj6UjgE2iN1+kY
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiOrDCAFJzPfAjcif3SOs138+s6EFAljdF3kACgkQ3SOs138+
s6EC8w/+JfJE0NCjzHpE9ZUBMuQTMmK7YFgWtMCxyaKiKJPBc4ejf2aWHCL2FB/r
hdDKT+X9zPmdsHzcxKFG06au2cX3sAPd61FyFLnhg3UcYVplMa6InInx1rUSqH0N
3TSKrCZnwvf8JK/cjpzaG9SfJI7WgR72Siklv2ki96HgJyBN9cB8g3afzJgE84uN
Yt03vgfS6e4GXDSXqG6/cOs/k7haIUg275bMr4H6aNPgsZPr9dT8T2UR3oWulmsT
R4px0xc0FzxPDHxeVWhG9RRJDY37odRtwfq86Sdk7HBGqc4NwYmovM1WiX9pNuj+
oKVMloIME1ceO8cBKeOd2r0H7dW8QnKASxXQ1e3AuvtvDvt55dloppnqIbvtaG2R
8D/qV+kmPWc1CxMf0cKGI+uoeuV9T2ERp+6L1/9J6BWa3ds6ygJzhiX7pgPrcdYC
IDkqAqn3yLAOO/wjVOdb9CeLajbGxNvubsyRegQpvOdCFa6HPJ40+NqooUXqbcaL
ylJ8hey4oqGbfllDMFICjN5ynGW/UAZNW1zMs797p1SL0iufUmaeO/Fqjtsza8IL
KcldJPHd+HxsRVG1pLuZt9yghxBGGSEyPjT71dZPlOAv5PMFVqut6Q+Tv+kZ2OiM
CoKxMFT8wAYjHUl5uTQDsWWe+Ytt8/A6AztJB8++MRcN7raeNeI=
=1MMa
-----END PGP SIGNATURE-----

--4Ckj6UjgE2iN1+kY--
