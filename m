From: Thierry Reding <thierry.reding@gmail.com>
Subject: Re: [PATCH v2 net-next] net: fix dma operation mode config for older
 versions
Date: Tue, 21 Mar 2017 21:42:25 +0100
Message-ID: <20170321204223.GA1064@mithrandir.ba.sec>
References: <3b8aeab69d2987db68c74f48a3ac13c7241e1542.1490118934.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="ZGiS0Q5IWpPtfppv"
Cc: davem@davemloft.net, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, clabbe.montjoie@gmail.com,
        ^Crgei.shtylyov@cogentembedded.com, netdev@vger.kernel.org
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:35593 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933109AbdCUUma (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 16:42:30 -0400
Received: by mail-wr0-f195.google.com with SMTP id u108so24187402wrb.2
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 13:42:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <3b8aeab69d2987db68c74f48a3ac13c7241e1542.1490118934.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--ZGiS0Q5IWpPtfppv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Mar 21, 2017 at 06:00:53PM +0000, Joao Pinto wrote:
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

--ZGiS0Q5IWpPtfppv
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiOrDCAFJzPfAjcif3SOs138+s6EFAljRkCsACgkQ3SOs138+
s6EGlA/+PAmcCde9s5qhqv5qOtkg79uTdSYfuDL2Qsfvz+ZJKIeYtuRD9Qz8RlFm
1P/defqe8bzLVk+2NUw88gGCJBHofIA3UBM1uLRwTtYE/qy600Tc4q+ZQ6Ofqogz
dzLdH6qUtwIjbE/Yi4mEjCeNXO7iBd2uVYSDR2H0r2VKdmQVBsVGBHL9hnozuEXn
04SysNMKY9qkXRGIgmEz/rwhTxDYa+M4R07ss2yahiFc+rRnRz2A3ISyoIaql4UM
VrYZ23g/qWA4htmYnBXbckSxNbIuMdKgwxForBWxHrqyxdRqncnCgsQrex4Z+8Cf
ScfkX9nkpCknvAjm6LK9NbhvgOfAnLQTaC7Cu1ZTke+g9V/4F+wfIb1ZQ6wG2FnN
2cJj3hqUV9wXTqirnUVDRdPKnbhEgtqnUUBEBfc8dmjcNFu8b9ensZb9SyCocSgX
Orf1Jdh398a31CGyckEo0O7zeJyvfjFq7YGeqS/jY9nuTiWMK1clt7OyrHltc4cz
Vao2bFCFRR18q8hkHqVNzzFiLPY1s1GYXLTzX/Km7tN3S73cby2KS4fsAbbboqNc
4dTiuo5qllZfxOO74rgywPb4mhWbOltdY/KfPTBTuVyX9KCWmaw2fa/fwTVZjl+n
ZSw4ZCsAO27/vWTKgrBsCPRAkmCrvF6nA58G+5eRXIaUyUeFrDI=
=6YSX
-----END PGP SIGNATURE-----

--ZGiS0Q5IWpPtfppv--
