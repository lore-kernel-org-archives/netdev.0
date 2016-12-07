From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [PATCH 4/4] vsock: cancel packets when failing to connect
Date: Wed, 7 Dec 2016 13:25:40 +0000
Message-ID: <20161207132540.GB31953@stefanha-x1.localdomain>
References: <1481104821-77294-1-git-send-email-bergwolf@gmail.com>
 <1481104821-77294-5-git-send-email-bergwolf@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="H1spWtNR+x+ondvy"
Cc: Stefan Hajnoczi <stefanha@redhat.com>, kvm@vger.kernel.org,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: Peng Tao <bergwolf@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1481104821-77294-5-git-send-email-bergwolf@gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--H1spWtNR+x+ondvy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Dec 07, 2016 at 06:00:21PM +0800, Peng Tao wrote:
> Otherwise we'll leave the packets queued until releasing vsock device.
> E.g., if guest is slow to start up, resulting ETIMEDOUT on connect, guest
> will get the connect requests from failed host sockets.
>=20
> Signed-off-by: Peng Tao <bergwolf@gmail.com>
> ---
>  include/linux/virtio_vsock.h            | 7 +++++++
>  net/vmw_vsock/af_vsock.c                | 7 +++++++
>  net/vmw_vsock/virtio_transport_common.c | 7 -------
>  3 files changed, 14 insertions(+), 7 deletions(-)

Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>

--H1spWtNR+x+ondvy
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJYSA3UAAoJEJykq7OBq3PIfLYIAK/NHdsh3l5nj0Ws2rJGXO/D
/+rUwcg21PoUrxoBPFVYXp369Z3v+sEB7livRL71Zrjt0h3kWLkU3EXG3wWF+Gbq
KZpuDbhJ/xgATSJTl9n6mje2V294YtJXss5IZJTBValQdPgZFemN9cgNr+7oeVLS
AkIZk8Zu+xV5J7XrOzj95gIoXq+qldrlTVe/6KI/jRSrLWvc/DmC8YQtovAFNZ4r
A690F4t57PyRM9qHD6TUyWyEbRbm2CQHj21c7pzN63wwzwjPLsh34UBKogOW/dMf
SeoNYqm9ffX13nQoDi3qB7xK09MNJyUkEaCL4S3JQRTToTc3NYTLBBIaWxFpK3M=
=I/iu
-----END PGP SIGNATURE-----

--H1spWtNR+x+ondvy--
