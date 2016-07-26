From: Leon Romanovsky <leonro@mellanox.com>
Subject: Re: [PATCH v2] net/mlx5_core/health: Remove deprecated
 create_singlethread_workqueue
Date: Tue, 26 Jul 2016 21:11:07 +0300
Message-ID: <20160726181107.GB4628@leon.nu>
References: <20160717051327.GA20674@leon.nu>
 <20160726170824.GA10721@Karyakshetra>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="aVD9QWMuhilNxW9f"
Cc: Matan Barak <matanb@mellanox.com>, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	Tejun Heo <tj@kernel.org>
To: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36514 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756511AbcGZSLN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 14:11:13 -0400
Received: by mail-wm0-f68.google.com with SMTP id x83so2878132wma.3
        for <netdev@vger.kernel.org>; Tue, 26 Jul 2016 11:11:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160726170824.GA10721@Karyakshetra>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--aVD9QWMuhilNxW9f
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jul 26, 2016 at 10:38:24PM +0530, Bhaktipriya Shridhar wrote:
> The workqueue health->wq was used as per device private health thread.
> This was done to perform delayed work.
>=20
> The workqueue has a single workitem(&health->work) and
> hence doesn't require ordering. It is involved in handling the health of
> the device and is not being used on a memory reclaim path.
> Hence, the singlethreaded workqueue has been replaced with the use of
> system_wq.
>=20
> Work item has been flushed in mlx5_health_cleanup() to ensure that
> there are no pending tasks while disconnecting the driver.
>=20
> Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
> ---
>  Changes in v2:
> 	-Updated commit description as per the feedback received.
>=20
>  drivers/net/ethernet/mellanox/mlx5/core/health.c | 7 ++-----
>  1 file changed, 2 insertions(+), 5 deletions(-)

Thanks,
Acked-by: Leon Romanovsky <leonro@mellanox.com>

--aVD9QWMuhilNxW9f
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXl6e7AAoJEORje4g2clinFjMP/inmr6U+sMdyDf7WmGuSMjg3
vEnx3oXkSM0Vv+OIA6MxH5wYZgERdh7UbzdLJTOjIBWx36KwlfC4RyK80RjveVVn
ggTIu9S8wgcWwAw9yknFPmQhSr4oA9E1ZwCdhsvPsdxjtPH8fQIdFe08JRlijKqj
OKCD2SQixLJjkMUSQAQlkL8kmLXPSPsYHLzQf9wrPzztIE6vU8Et/NkXCCAB8D0K
u5CZ6qD6491wNwahuJ8Ouisp2Q+f7j2sfF0ekwiDW+gQ/dTUQen/Tlyoc0VSBucI
HdflJ7xktod+7gZMxaN4ZbS713xMCxgcnhn/HvkcbHuUt74k8EnL0VJGzXqikAoL
p3J4K0HoUecv/E+o6t3NESlK3e760i7qpTuUr41U8qG7vNfL9hfEIDJLGJ1dj2z4
Vev5EgDGIcemL35gS13nzSIdRwyZezG4/2077YYQ9OCWazL/smI8kVPC4/hIUQJS
IWW5+/UOOjC1o3qOBAzDEIzuIwMF4sbVj5x7pe7WSsMjSisvgTzmJttcp2qnFtXz
4iCpT4R+kiS05AEFbgvk4Xg3uD6hqbDDukyCBB2CKRbH6dmqSjkqv55VSyD+SeVS
iL7aZnZq+pTl2Kcm77U+xcBsGl9vH6hp4FEKk+czD4vr5YLs/Ubb+T0azLbGCUp8
848jfEiWZoQp6bbSsIyb
=c4pD
-----END PGP SIGNATURE-----

--aVD9QWMuhilNxW9f--
