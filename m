From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH] net/mlx5_core/pagealloc: Remove deprecated
 create_singlethread_workqueue
Date: Sun, 31 Jul 2016 09:35:13 +0300
Message-ID: <20160731063513.GW4628@leon.nu>
References: <20160728081949.GA5561@Karyakshetra>
 <20160728093735.GO4628@leon.nu>
 <20160729122237.GG2542@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="7uidztUHYC105IRM"
Cc: Bhaktipriya Shridhar <bhaktipriya96-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160729122237.GG2542-qYNAdHglDFBN0TnZuCh8vA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--7uidztUHYC105IRM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jul 29, 2016 at 08:22:37AM -0400, Tejun Heo wrote:
> Hello,
>=20
> On Thu, Jul 28, 2016 at 12:37:35PM +0300, Leon Romanovsky wrote:
> > Did you test this patch? Did you notice the memory reclaim path nature
> > of this work?
>=20
> The conversion uses WQ_MEM_RECLAIM, which is standard for all
> workqueues which can stall packet processing if stalled.  The
> requirement comes from nfs or block devices over network.

The title stays "remove deprecated create_singlethread_workqueue" and if
we put aside the word "deprecated", the code moves from ordered
workqueue to unordered workqueue and changes max_active count which
isn't expressed in commit message.

For reclaim paths, I want to be extra caution and want to see
justification for doing that along with understanding if it is tested or
not.

Right now, I'm feeling that I'm participating in soapie where one sends
patch for every line, waits and sends the same patch for another file.
It is worth to send one patch set and let us to test it all in once.

Thanks.

>=20
> Thanks.
>=20
> --=20
> tejun
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--7uidztUHYC105IRM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXnZwhAAoJEORje4g2clinMmEQAJeUsY1s9+pdwsuE4W/XGaTU
in5iWOxXqny0ElIFX6mVd+qb3YlzJoDMMjO9bD4wWdn1wnmYlo/eMVzdjdXWzFYu
zOMCV494J8hojqCF2h/CgjaFsWDZev8Q67kQZGrTNIMWk2cozT/jBpU4bGxOpLlo
1lt938+eCbnCmb7bokencLKS8ljJslvYrC92T0+Z3GALc9LHuTbvyhyzvi3C77eM
DZRQuN82kpUqhp611M6iLRZKUci2hhYiLqlsnKXf6EbMbfQcIu8P4LPEOaAF3zCx
QQr9Vo8HvQdcB29FJeerCMkMfYM7cd7msM+/9JEhwqgr6qo8Bgp3PX6xqEp3Z66s
CDtSmfTcCh/NLVVTXkUSTwL56FuWK2dTqy0ix/T+YG0cYdZmLbf16AMtWEVZAEy6
BKTZkwi/JpxWbr6N4ABx3oROvHCELitswqwMEMrZDddb56RjGuctqKNcuAFn3feI
15AltfTTnpvyH+TxHJ06CmCdtGgKXGdbx6yAk8/4r0qA0bZKL0fKkbhiLJOe9k1M
3/0Sanv2EY9IRxHJiKxs4Cbi3k7xfQYdda/ZOasMjaiN5p/T3vO9OsESuiluxiNp
6if18XanmkmRowctZbRcdj/Z6V/8BmxPtR1Rnkm4lwMfAs0cbvwXjAx4+erTjcdi
y0LQ5DE9KHse5+6Ned2K
=5lHY
-----END PGP SIGNATURE-----

--7uidztUHYC105IRM--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
