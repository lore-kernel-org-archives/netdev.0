From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [PATCH net-next V2 1/3] vhost: better detection of available
	buffers
Date: Tue, 3 Jan 2017 13:08:30 +0000
Message-ID: <20170103130830.GA14707@stefanha-x1.localdomain>
References: <1482912571-3157-1-git-send-email-jasowang@redhat.com>
	<1482912571-3157-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5593131570211619521=="
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org, mst@redhat.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1482912571-3157-2-git-send-email-jasowang@redhat.com>
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


--===============5593131570211619521==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="2oS5YaxWCcQjTEyO"
Content-Disposition: inline


--2oS5YaxWCcQjTEyO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Dec 28, 2016 at 04:09:29PM +0800, Jason Wang wrote:
> This patch tries to do several tweaks on vhost_vq_avail_empty() for a
> better performance:
>=20
> - check cached avail index first which could avoid userspace memory acces=
s.
> - using unlikely() for the failure of userspace access
> - check vq->last_avail_idx instead of cached avail index as the last
>   step.
>=20
> This patch is need for batching supports which needs to peek whether
> or not there's still available buffers in the ring.
>=20
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  drivers/vhost/vhost.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)

Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>

--2oS5YaxWCcQjTEyO
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJYa6JOAAoJEJykq7OBq3PIDqIIALlfkoB88iYF8bb4Zf7u+uyA
vtuy/uIAv4ENa2gPdr8aVH5vCGkbKN430AkZrXCkXFF/Im50I/59u0RJJ1B2EAOA
tTr27am3shyGl03f8svSDlE3wtaWm/2oReWtLBWWNuyd8sz4S5TU+MJRD24vsiP+
h8nAbg7dmSavfIKbiKcJnn3XgZfxcrOp6I8aGstfhTI2szqYY3t2zomIcSr+l3fP
OkTzsoC9GmWqQi43N0jHNjioh3gEaPNxMISJxqaJoP33hVk2NpK6w7hVFr9pEcgB
y8sQ23con2Hdbxt3xx7vHi4LzCj0lH5QhuAz0b6TFQ3dyhWDTB06tQReE4IW1kQ=
=3bfK
-----END PGP SIGNATURE-----

--2oS5YaxWCcQjTEyO--

--===============5593131570211619521==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============5593131570211619521==--
