From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [PATCH] vhost/scsi: Remove unused but set variable
Date: Tue, 15 Nov 2016 14:40:15 +0000
Message-ID: <20161115144015.GA17672@stefanha-x1.localdomain>
References: <20161111132710.25804-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="pf9I7BMVVzbSWLtt"
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>, kvm@vger.kernel.org,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:32917 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936584AbcKOOkT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 09:40:19 -0500
Content-Disposition: inline
In-Reply-To: <20161111132710.25804-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--pf9I7BMVVzbSWLtt
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Nov 11, 2016 at 02:27:10PM +0100, Tobias Klauser wrote:
> Remove the unused but set variable se_tpg in vhost_scsi_nexus_cb() to
> fix the following GCC warning when building with 'W=3D1':
>=20
>   drivers/vhost/scsi.c:1752:26: warning: variable =E2=80=98se_tpg=E2=80=
=99 set but not used
>=20
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> ---
>  drivers/vhost/scsi.c | 2 --
>  1 file changed, 2 deletions(-)

Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>

--pf9I7BMVVzbSWLtt
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJYKx5PAAoJEJykq7OBq3PImQcH/Aoa5H9+lNxRYg8r2gWqmK2q
tmr1SFEOp5+cvnlV3JtvMgdlxtX75JQBxlZmysV6e1SBGefZbfdv56HnKLXzQajS
6c2+78i5A9SLcXCh+PG+q4VcNwQ3TXHA6TZoq/VFEjgYAxV8GaXCpzcj6mSfg7G2
PWx0UxExCM/1lRJg15RSHtWtiD1yJ2BcYUz/gUvLZWw00FIrYoJo/em/weMSHrpl
eeXF+IvSIFcxbpMYPeqiMJW0q8PrHvbDD/RE8qqBOo1GtIIsB1A48j/KpTcx8Uv4
jfemoid0F1ognvqzt4rW7QpOVJ/YaaA4GS0nnRqAufT0Bd1LgJkALcWRA2nC6jI=
=9RfQ
-----END PGP SIGNATURE-----

--pf9I7BMVVzbSWLtt--
