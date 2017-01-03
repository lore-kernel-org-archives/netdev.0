From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [PATCH net-next V2 2/3] vhost_net: tx batching
Date: Tue, 3 Jan 2017 13:16:30 +0000
Message-ID: <20170103131630.GB14707@stefanha-x1.localdomain>
References: <1482912571-3157-1-git-send-email-jasowang@redhat.com>
	<1482912571-3157-3-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7336991909795372643=="
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org, mst@redhat.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1482912571-3157-3-git-send-email-jasowang@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org


--===============7336991909795372643==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="LpQ9ahxlCli8rRTG"
Content-Disposition: inline


--LpQ9ahxlCli8rRTG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Dec 28, 2016 at 04:09:30PM +0800, Jason Wang wrote:
> This patch tries to utilize tuntap rx batching by peeking the tx
> virtqueue during transmission, if there's more available buffers in
> the virtqueue, set MSG_MORE flag for a hint for backend (e.g tuntap)
> to batch the packets.
>=20
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  drivers/vhost/net.c | 23 ++++++++++++++++++++---
>  1 file changed, 20 insertions(+), 3 deletions(-)

Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>

--LpQ9ahxlCli8rRTG
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJYa6QuAAoJEJykq7OBq3PItbkH/jo+NKDhV0qrUx7lBvRPBveW
8ojg5zXdLHyP3ydXi3LDFcwGKoL5VhStwL4BAaqXUYTgiFC5BBwABnIyQ1Iod0Jj
3BNw3QmuFTpo2s2E4Th4ClBIsgDv4l80ukJTjiy35rdaZg1qtLiFhz7L6e8Bgbsz
eT6dEzHWvb8iEq+CBFO589KBKxnQE17T0KNUTTzXtgUXKvwIVWZQlE+keDN9W8Kx
3eTr2QYUhkPCxVZysYjNTpX4EfxzRd1pgRDQQjHEfFdybMIHpym1nFzlKBRPOnoZ
CecPpfoNwIHO6pST5Q9oyZtuqPKM8IIHQ0v09bFM1yo/OwA+4oW644gqxJXF1ig=
=O5e4
-----END PGP SIGNATURE-----

--LpQ9ahxlCli8rRTG--

--===============7336991909795372643==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============7336991909795372643==--
