From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [PATCH 2/2] vhost: remove unnecessary smp_mb from vhost_work_queue
Date: Wed, 7 Dec 2016 13:10:21 +0000
Message-ID: <20161207131021.GB31552@stefanha-x1.localdomain>
References: <1481104340-77035-1-git-send-email-bergwolf@gmail.com>
	<1481104340-77035-2-git-send-email-bergwolf@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5446060131681487014=="
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	Stefan Hajnoczi <stefanha@redhat.com>,
	virtualization@lists.linux-foundation.org
To: Peng Tao <bergwolf@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1481104340-77035-2-git-send-email-bergwolf@gmail.com>
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


--===============5446060131681487014==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="DKU6Jbt7q3WqK7+M"
Content-Disposition: inline


--DKU6Jbt7q3WqK7+M
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Dec 07, 2016 at 05:52:19PM +0800, Peng Tao wrote:
> test_and_set_bit() already implies a memory barrier.
>=20
> Signed-off-by: Peng Tao <bergwolf@gmail.com>
> ---
>  drivers/vhost/vhost.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>

--DKU6Jbt7q3WqK7+M
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJYSAo9AAoJEJykq7OBq3PIX4UH/AoLPgpXAXrkq7UHZLnNvM1J
DLxy2ie1ZciyyH7AcyNQcTCzqVAwPD8+/hA5ptAJ0K9M20NiPGz7bNDiELf9q0Zt
H6klHolnv9Nv6WJPXQHJ7pUr/FlstGcBtxl5lolNCoCZUDUV7YvuXRgxy5oPPygo
0o7iE4Zzj5kQX88pNTiJgHlpM/K97g2AbGhmk1oYuu0JiMngz9FS8nDuWPgcovN4
O29Br6M0CQwB2ewng1aekxh828Mobke6KEqMX72C06TPRZg4c9P2/ZNtByG0p0l3
eVIq/bEhjFgt3AFW+hE13v1MDWxYsgeBe49W929dEhw5kYSmw39OeCK9BThroAo=
=Mlu/
-----END PGP SIGNATURE-----

--DKU6Jbt7q3WqK7+M--

--===============5446060131681487014==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============5446060131681487014==--
