From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH 09/10] vsock/virtio: fix src/dst cid format
Date: Wed, 7 Dec 2016 14:09:23 +0000
Message-ID: <20161207140923.GE32099@stefanha-x1.localdomain>
References: <1481038106-24899-1-git-send-email-mst@redhat.com>
	<1481038106-24899-10-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6213421599729140140=="
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org, virtualization@lists.linux-foundation.org,
	"David S. Miller" <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1481038106-24899-10-git-send-email-mst@redhat.com>
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


--===============6213421599729140140==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Dzs2zDY0zgkG72+7"
Content-Disposition: inline


--Dzs2zDY0zgkG72+7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Dec 06, 2016 at 05:41:02PM +0200, Michael S. Tsirkin wrote:
> These fields are 64 bit, using le32_to_cpu and friends
> on these will not do the right thing.
> Fix this up.
>=20
> Cc: stable@vger.kernel.org
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  net/vmw_vsock/virtio_transport_common.c | 14 +++++++-------
>  1 file changed, 7 insertions(+), 7 deletions(-)

Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>

--Dzs2zDY0zgkG72+7
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJYSBgTAAoJEJykq7OBq3PImSsIAJmtq2NhBugg/bFvHE2ZgUU8
z+sR8xJM5LyK004Qi7uV7HzmXUbD/bJ9ao0bAK1SENYwGIUziqhm4HUWZhsnrLeC
ZDLvcdwqs6T6j+6RAki8hwB3x9oKgYlZ/2OsAU//QFdVIJwsBCHfgEClmryLI27B
mSGtDEf5bhnrLuT9mLKloObVlWCTxlf+V7jk/y/00RfRsY4CD2xZdfj2z4WjDJo3
D4gp6NDOq5dqSr5/ucgPhzG4fifRe3C49ZbUxPZvbl+uD+68slA9cc5jhav95Kal
7oe+QOaOUkVxuUhSpHce0+n476N5e4rbIBWGrxGFtnzxh+B4+FXPxuyL4XdZdHk=
=bYLP
-----END PGP SIGNATURE-----

--Dzs2zDY0zgkG72+7--

--===============6213421599729140140==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============6213421599729140140==--
