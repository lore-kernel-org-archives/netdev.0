From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH 07/10] vsock/virtio: add a missing __le annotation
Date: Wed, 7 Dec 2016 14:09:07 +0000
Message-ID: <20161207140907.GC32099@stefanha-x1.localdomain>
References: <1481038106-24899-1-git-send-email-mst@redhat.com>
	<1481038106-24899-8-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4711672217056365269=="
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	"David S. Miller" <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1481038106-24899-8-git-send-email-mst@redhat.com>
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


--===============4711672217056365269==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="0lnxQi9hkpPO77W3"
Content-Disposition: inline


--0lnxQi9hkpPO77W3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Dec 06, 2016 at 05:40:57PM +0200, Michael S. Tsirkin wrote:
> guest cid is read from config space, therefore it's in little endian
> format and is treated as such, annotate it accordingly.
>=20
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  net/vmw_vsock/virtio_transport.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>

--0lnxQi9hkpPO77W3
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJYSBgDAAoJEJykq7OBq3PIeTIH/i6BbER4AD5fvn58S6AD1pfh
Pmv4QDzy3XQyDkA4mbWW4bOYF9OcrtXDdR3k3MX5YON7QLnpapM29QzFOd7fOKe/
nq4kAP+fnuG5idYu8RCuTHMTdL+k4GxUpTAPoxTeH4prhJIeM5v0d0cbjQ/PjOIa
VsfjUgBDNcaFqSCRrcpTZQBZ1wri4Sj2f3k3ijyXgal0/M7teh8N8nDdn+Xjlqso
z23pZaXiiWzW8rpQ9bGMP0pDjAovkMhFU+vIm8XIUPByPjj1+WumZCvEKUxF/Fsy
erZ/IieJi+xUSL5z4JbLnGc6utYI3QbRcBtommB1Hq6Fs5y2EK+PcA+UF1wS44w=
=pxMV
-----END PGP SIGNATURE-----

--0lnxQi9hkpPO77W3--

--===============4711672217056365269==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============4711672217056365269==--
