From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH 10/10] virtio: enable endian checks for sparse builds
Date: Wed, 7 Dec 2016 14:09:33 +0000
Message-ID: <20161207140933.GF32099@stefanha-x1.localdomain>
References: <1481038106-24899-1-git-send-email-mst@redhat.com>
	<1481038106-24899-11-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7466233140133078509=="
Cc: kvm@vger.kernel.org, Neil Armstrong <narmstrong@baylibre.com>,
	David Airlie <airlied@linux.ie>, linux-remoteproc@vger.kernel.org,
	dri-devel@lists.freedesktop.org, virtualization@lists.linux-foundation.org,
	linux-s390@vger.kernel.org,
	"James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	linux-scsi@vger.kernel.org, v9fs-developer@lists.sourceforge.net,
	Asias He <asias@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	linux-kbuild@vger.kernel.org, Jens Axboe <axboe@fb.com>,
	Michal Marek <mmarek@suse.com>, Matt Mackall <mpm@selenic.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-kernel@vger.kernel.org, linux-crypto@vger.kernel.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1481038106-24899-11-git-send-email-mst@redhat.com>
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


--===============7466233140133078509==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="GLp9dJVi+aaipsRk"
Content-Disposition: inline


--GLp9dJVi+aaipsRk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Dec 06, 2016 at 05:41:05PM +0200, Michael S. Tsirkin wrote:
> __CHECK_ENDIAN__ isn't on by default presumably because
> it triggers too many sparse warnings for correct code.
> But virtio is now clean of these warnings, and
> we want to keep it this way - enable this for
> sparse builds.
>=20
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>=20
> It seems that there should be a better way to do it,
> but this works too.
>=20
>  drivers/block/Makefile          | 1 +
>  drivers/char/Makefile           | 1 +
>  drivers/char/hw_random/Makefile | 2 ++
>  drivers/gpu/drm/virtio/Makefile | 1 +
>  drivers/net/Makefile            | 3 +++
>  drivers/net/caif/Makefile       | 1 +
>  drivers/rpmsg/Makefile          | 1 +
>  drivers/s390/virtio/Makefile    | 2 ++
>  drivers/scsi/Makefile           | 1 +
>  drivers/vhost/Makefile          | 1 +
>  drivers/virtio/Makefile         | 3 +++
>  net/9p/Makefile                 | 1 +
>  net/packet/Makefile             | 1 +
>  net/vmw_vsock/Makefile          | 2 ++
>  14 files changed, 21 insertions(+)

Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>

--GLp9dJVi+aaipsRk
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJYSBgdAAoJEJykq7OBq3PIErIIALcfuXKP5HgamgpQoZkN0Uc0
2n2uVTdzArmnFB44EWnkmW+iYjCl3HfmHgtoWPwsUKoY/RDBuL8x9wNSrOfDzSMf
ymjii6GPxe3fJ4xlvzAmueh0F4wfFeKl+jrO7jm3B1vIhJh6NzEgQZJgGxmpNYvE
X0o9IKPe5pr+x3ZAec1LMzsv9CvtJObwO3bVgAtQQlA7hlvewrbZkxgmKAojibGG
Mdv+oNGtpp8ePXN9c0EdhLFbPF3MY9YHf0DbirN5CXp7KP1GH9FgWaOKx0n0v8IB
3KqF7wUADa/eIWrIW1FaSy9DeGfihiwwrWaEcg/c0LoweS6OLwGhCJTXfp45GJk=
=SL7g
-----END PGP SIGNATURE-----

--GLp9dJVi+aaipsRk--

--===============7466233140133078509==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============7466233140133078509==--
