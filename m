From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC v2 04/12] qedr: Add support for user context verbs
Date: Tue, 20 Sep 2016 19:45:56 +0300
Message-ID: <20160920164556.GS26673@leon.nu>
References: <1474367764-9555-1-git-send-email-Ram.Amrani@cavium.com>
 <1474367764-9555-5-git-send-email-Ram.Amrani@cavium.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="uX7BrQs69PbBafpd"
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org,
        Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org, Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org,
        rajesh.borundia-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ram Amrani <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1474367764-9555-5-git-send-email-Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--uX7BrQs69PbBafpd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Sep 20, 2016 at 01:35:56PM +0300, Ram Amrani wrote:
> From: Ram amrani <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
>
> Add support for ucontext, query port, add and del gid verbs.
>
> Signed-off-by: Rajesh Borundia <rajesh.borundia-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Ram Amrani <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> ---

<...>

> +++ b/drivers/infiniband/hw/qedr/verbs.c
> @@ -0,0 +1,417 @@
> +/* QLogic qed NIC Driver
> + * Copyright (c) 2015 QLogic Corporation
> + *
> + * This software is available under the terms of the GNU General Public License
> + * (GPL) Version 2, available from the file COPYING in the main directory of
> + * this source tree.
> + */

<...>

> --- /dev/null
> +++ b/drivers/infiniband/hw/qedr/verbs.h
> @@ -0,0 +1,26 @@
> +/* QLogic qed NIC Driver
> + * Copyright (c) 2015 QLogic Corporation
> + *
> + * This software is available under the terms of the GNU General Public License
> + * (GPL) Version 2, available from the file COPYING in the main directory of
> + * this source tree.
> + */

<...>

> +++ b/include/uapi/rdma/providers/qedr-abi.h
> @@ -0,0 +1,27 @@
> +/* QLogic qed NIC Driver
> + * Copyright (c) 2015 QLogic Corporation
> + *
> + * This software is available under the terms of the GNU General Public License
> + * (GPL) Version 2, available from the file COPYING in the main directory of
> + * this source tree.
> + */

Are you sure that you want GPL-only license?


> +#ifndef __QEDR_USER_H__
> +#define __QEDR_USER_H__
> +
> +#define QEDR_ABI_VERSION		(6)

Is it possible to start new file with new driver from ABI version 1 and
not 6?

> +
> +/* user kernel communication data structures. */
> +
> +struct qedr_alloc_ucontext_resp {
> +	u64 db_pa;
> +	u32 db_size;
> +
> +	u32 max_send_wr;
> +	u32 max_recv_wr;
> +	u32 max_srq_wr;
> +	u32 sges_per_send_wr;
> +	u32 sges_per_recv_wr;
> +	u32 sges_per_srq_wr;
> +	int max_cqes;
> +};
> +#endif /* __QEDR_USER_H__ */
> --
> 1.8.3.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--uX7BrQs69PbBafpd
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX4WfEAAoJEORje4g2clinjHgP/1ylaW22qLIrxlaoy135YAiL
7Fjl1KAJcanawwoH0p/suq4AHeibSC8peFMCoUmxApbqmnk7VPlLOONsEZ/9s1yd
HyOhg9nKO6kld/gHxWpoJhp0GIuHu4h4j9nC9Tel7HVzos3jPjDpv6DIPryK1ki0
fFSn+ukVMciHDVb6bX3w4HTpA/wp8myl+kh4lJUAkFmgLql7ZmOkxjiYwfdLMcxY
YALyj9JDaEf3eNs0NNN43lCu1fINxobJTn8cG4emNZQarrMnwzy126NEVOy3qiXV
UTRw0yoeLQJ/KPdhnnO9gwB0LZcY3vB97sKI73qVopjNoTc+xj7xzTIqKJUgpMg3
mgEAcSNKm6f0e9Yt489CjI5cVkM4/0f+Kv1Z6lRBbOsLq3rd+70kCNaDDAp3+S9d
S0c/pZQ7oNbrEV56LEkLFGegSy4mM7gVeptIGXFfcRBftvuw34W116LtLM4+FUWr
I7FKNiKN1BbAZDUFHKQo5Aqv2YLcCZ/DExCfzqYnVy8pyTwxZKk5BAq4Z2NFm8ak
EOyeaKF7aFZNkN4GgfLZQJZKykvc4HxShUSs1o4U3ilVGSFrP8NvyNL32Z0mmYGW
xoErjQskquGUS7ukIN5I/lbpCYT0m4ZZqdnyas0oUvsHHS8XkZR3RdMYlYKWfiGX
X7qt6Us+qxShhQ64mtEq
=07u7
-----END PGP SIGNATURE-----

--uX7BrQs69PbBafpd--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
