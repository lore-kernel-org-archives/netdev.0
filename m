From: Thierry Reding <treding@nvidia.com>
Subject: Re: [PATCH 3/4] net: stmmac: adding multiple buffers for TX
Date: Tue, 4 Apr 2017 21:19:58 +0200
Message-ID: <20170404191958.GD24271@ulmo.ba.sec>
References: <433505e9e631db632be7a37a316a03ace802863c.1491328304.git.jpinto@synopsys.com>
 <da10bfa9db18e1f709cba874fb25d7bd36915eef.1491328304.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="EP0wieDxd4TSJjHq"
Cc: <davem@davemloft.net>, <clabbe.montjoie@gmail.com>,
        <niklas.cassel@axis.com>, <netdev@vger.kernel.org>
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate14.nvidia.com ([216.228.121.143]:3240 "EHLO
        hqemgate14.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754728AbdDDTUF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 15:20:05 -0400
In-Reply-To: <da10bfa9db18e1f709cba874fb25d7bd36915eef.1491328304.git.jpinto@synopsys.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--EP0wieDxd4TSJjHq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Apr 04, 2017 at 06:54:26PM +0100, Joao Pinto wrote:
> This patch adds the structure stmmac_tx_queue which contains
> tx queues specific data (previously in stmmac_priv).
>=20
> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/chain_mode.c  |  38 +-
>  drivers/net/ethernet/stmicro/stmmac/ring_mode.c   |  46 +-
>  drivers/net/ethernet/stmicro/stmmac/stmmac.h      |  26 +-
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 521 +++++++++++++---=
------
>  4 files changed, 375 insertions(+), 256 deletions(-)

Looks good to me:

Reviewed-by: Thierry Reding <treding@nvidia.com>

And works fine on Tegra186, so:

Tested-by: Thierry Reding <treding@nvidia.com>

--EP0wieDxd4TSJjHq
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiOrDCAFJzPfAjcif3SOs138+s6EFAljj8d4ACgkQ3SOs138+
s6ERuQ//ZsiuiYfNbQb0gxfn50ChnENHR7pBar58+Z8gVkQOGmfBn7duLLzg+OOw
j68GVFdQnRdhV1jSEM+dm4sDsRaqUNpEEdV2r9e8NVxOwqUZa6gxJrU/sjrImC9y
obz7vmqrLqCAvoMvRgDluKG6ov8Tp/sqAHCudSKW+JZ5kFKh1YoCVMompYmVwFRR
LCTTVw7HGQdhnBctVixkWzPKSsqgsgEGuRtGKdWlKLYXXrxzozF87FCybZRsfrhS
Wp5FtGyRaG9trtN1H4WbIB4TvDKEK5cHFe2LHbLHqFrLaVjaPj2iLXa7ZwNNDbt1
70vBPFHoqP1QqEKUmWL45qQAXqWv/epbkDOKQ9BhNvx/PRlQJsfj4RfPdkurTToQ
ylf7FS0homJXtfHgwpI07FMC/hSJq/Td/e7vE35qtjdvctH+P4h4uPoWZH/icxAJ
pDVw95TloCIU3Hv8HVkHQ1FsQf9aPy83Yhp6LAeNp3UIqBQD0C+5KOGS8rhyyLOU
myDb6lr8SyDV89OFNg0WiqmnEpWM+HcUNmnYJTuhbfcHNiJo8mbvz5t3fPwu9tHY
OEjdSBAPtkcx7qy9bKbx4YtOdtRLx7aESlqHELx8kvy+x6IddST655g3/TRc7rZC
KxC3IGf04n56J8my3KNeY7zoM/IVLaCrjSAGNPWZUkB3jnDmQ8g=
=A1X+
-----END PGP SIGNATURE-----

--EP0wieDxd4TSJjHq--
