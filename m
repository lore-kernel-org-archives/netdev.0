From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH][V2] VSOCK: remove unnecessary ternary operator on return
 value
Date: Wed, 29 Mar 2017 19:35:58 +0100
Message-ID: <20170329183558.GA18142@stefanha-x1.localdomain>
References: <20170329153355.17525-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="vtzGhvizbBRQ85DL"
Cc: "David S . Miller" <davem@davemloft.net>,
        Jorgen Hansen <jhansen@vmware.com>,
        "Michael S . Tsirkin" <mst@redhat.com>,
        Adit Ranadive <aditr@vmware.com>,
        George Zhang <georgezhang@vmware.com>,
        Julia Lawall <julia.lawall@lip6.fr>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48470 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752637AbdC2SgN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 29 Mar 2017 14:36:13 -0400
Content-Disposition: inline
In-Reply-To: <20170329153355.17525-1-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--vtzGhvizbBRQ85DL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Mar 29, 2017 at 04:33:55PM +0100, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
>=20
> Rather than assign the positive errno values to ret and then
> checking if it is positive and flip the sign, just return the
> errno value.
>=20
> Detected by CoverityScan, CID#986649 ("Logically Dead Code")
>=20
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  net/vmw_vsock/vmci_transport.c | 22 +++++++---------------
>  1 file changed, 7 insertions(+), 15 deletions(-)

Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>

--vtzGhvizbBRQ85DL
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJY2/6OAAoJEJykq7OBq3PI/cUH/RCRDxR4eEGjy5+gOUJd5/Go
FVDO2qYL72HQxQpK/8/MFAHJDIIA4yNu/tColyK3eIFGs95NAI2e9tf518ldmjdG
sFHhGuezkAOTk3RLH+vUF7Dm3PWoHrSdT18N47ZnTO7PqAKK4mELOZGybdRUibaD
LLpcmDpKH++Ys7yHAfDnWlzCdmK6hWK17HZHMRWYZVuNHyY0MQuONrnA+2Pj8/H3
kojAAIhubjUPWyxLNhcU/qqnNmRPB5qQoVYyjmTcOh7ePNjs56BAasAYQ2Oy2/WL
y3Elt30l44Apj8wDMn/PrUDaSp+ZG6kzibZQ5oBMh5CZhUCmLHC7D0U+IcBI86I=
=n2yg
-----END PGP SIGNATURE-----

--vtzGhvizbBRQ85DL--
