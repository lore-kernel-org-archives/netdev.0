From: Thierry Reding <thierry.reding@gmail.com>
Subject: Re: [PATCH v2 net-next] net: fix dma operation mode config for older
 versions
Date: Tue, 21 Mar 2017 21:46:47 +0100
Message-ID: <20170321204644.GB1064@mithrandir.ba.sec>
References: <3b8aeab69d2987db68c74f48a3ac13c7241e1542.1490118934.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="PmA2V3Z32TCmWXqI"
Cc: davem@davemloft.net, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, clabbe.montjoie@gmail.com,
        sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35651 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932478AbdCUUrp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 16:47:45 -0400
Received: by mail-wm0-f67.google.com with SMTP id z133so5304770wmb.2
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 13:46:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <3b8aeab69d2987db68c74f48a3ac13c7241e1542.1490118934.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--PmA2V3Z32TCmWXqI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Resending with Sergei's proper email address.

On Tue, Mar 21, 2017 at 06:02:36PM +0000, Joao Pinto wrote:
> This patch fixes a bug introduced in:
> commit 6deee2221e11 ("net: stmmac: prepare dma op mode config for multiple
> queues")
>=20
> The dma operation mode configuration routine was wrongly moved to a
> function (stmmac_mtl_configuration) that is only executed if the
> core version is >=3D 4.00.
>=20
> Reported-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)

With Florian's comments addressed, this is:

Reviewed-by: Thierry Reding <thierry.reding@gmail.com>

--PmA2V3Z32TCmWXqI
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiOrDCAFJzPfAjcif3SOs138+s6EFAljRkTQACgkQ3SOs138+
s6FaCRAApNsI4l6nw2GTlJfB3Qwjzu8kzh/ZVuAoR51EFI+CE5Dxt0nW3yYn/tHr
m2a1uVZKo3DQ1oEQNDvIg2k4vfU9vC9nKchOVMTa9CcL8htbPmUdvLJ7UHGbDdn1
1AKFGsjwvIVSvuIAr0fIqg1xn0304iHJdRFeTAHjjRcreshJWI3kPTohvMZ7E0qX
OP6cyqRd3bJKjETZK5DBAlhRHsY962ARfhQTAnTCkosCY98kG3yZnCFci4bCOFq7
jKvo67785ayn8lIxY8w4LqREOVvHAWA/6qhle5d3GTJxZaH2aD87jogmgDJfBePt
/OOnn9HTAAlYIqvhEC4IigDQ4clfRlCokD0Fs89TYn3hoaNSGSqZj9VKhHrUwSpq
5piERxBiTMzp0T9oUyXMx2znSe3Adtl8+n73P5zcV3uwQa2Caxl/zm+3wQrLxC1u
t15+tjEkdbnttniDBCqdzvjDk1MlB+bk/l6QCvSPn2l2As/4aCjvbfbN0jW9M4oz
Lx4yvX2wbXxiEYC5bEQL0oSRef7qKqwgw/CkaeCWPB76BiAmgQJWjsL6zqk5RV/W
rxuAPDGhz9+Pm3Gvo/55ATyt1XGF9wh1fA7el1/qLkQtdcpdi2VCWIpVxdn4feRc
1lONvyufGB0nGD0LKE8sj5xcmYoTvuzPhcoeY+jXNXXn7fpNmpc=
=v/tA
-----END PGP SIGNATURE-----

--PmA2V3Z32TCmWXqI--
