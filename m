From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCHv2 1/4] rds: ib: drop unnecessary rdma_reject
Date: Sun, 12 Mar 2017 21:33:57 +0200
Message-ID: <20170312193357.GH2079@mtr-leonro.local>
References: <1489306078-3354-1-git-send-email-yanjun.zhu@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="k3qmt+ucFURmlhDS"
Cc: santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org
To: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1489306078-3354-1-git-send-email-yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--k3qmt+ucFURmlhDS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Mar 12, 2017 at 04:07:55AM -0400, Zhu Yanjun wrote:
> When rdma_accept fails, rdma_reject is called in it. As such, it is
> not necessary to execute rdma_reject again.
>
> Cc: Joe Jin <joe.jin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> Cc: Junxiao Bi <junxiao.bi-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> Acked-by: Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> ---
> Change from v1 to v2:
>   Add the acker.
>
>  net/rds/ib_cm.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
> index ce3775a..eca3d5f 100644
> --- a/net/rds/ib_cm.c
> +++ b/net/rds/ib_cm.c
> @@ -677,8 +677,7 @@ int rds_ib_cm_handle_connect(struct rdma_cm_id *cm_id,
>  		event->param.conn.initiator_depth);
>
>  	/* rdma_accept() calls rdma_reject() internally if it fails */
> -	err = rdma_accept(cm_id, &conn_param);
> -	if (err)
> +	if (rdma_accept(cm_id, &conn_param))
>  		rds_ib_conn_error(conn, "rdma_accept failed (%d)\n", err);

You omitted initialization of "err" variable which you print here ^^^^^.

>
>  out:
> --
> 2.7.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--k3qmt+ucFURmlhDS
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAljFoqQACgkQ5GN7iDZy
WKd8whAAw7s60uGoO4dviGaP893t8o75Yhoi3AKW8audapUw/q7tiik6pTyMiQkb
cMJ+ZtWu33GUcwxmlYqB6RofhEG59WNPcnOTuVsfiPEGWRn9VneRi6ZN+M4yrH7V
bFo+zWwQrBp7srNr8oo/l34TpLubecUhOMr7pP0tuE9NfkLUYlVxrJPd8JAwxOfU
mIBE7uFz0P8Mf7ykzWcACrmJY6/SLpUE1BVgRFZK9RIIz+Tte1lq+Ihp69b1S9OW
3gdE8qpdjEfcE/p0hrmQlZmmUFLGp99z8ufbHHL7TG3cz7bA705awBskEEKsFFUM
75Uevmkiwvs4U05BmFS6BpkIZdAkhnJRiP4mzi+Agm2z1BqAcybZXijHLmZPtxSQ
/c0HIIbzHuRoZvCxC33kTVXT8k+8pSPKaA+C9mTcmd4e2CRAw+/Qg4hW5whZz5gL
gjOqFsrjAJRtEwp0w9TV+v9ECjYiyF4zaTfUmxbbwGHegZRvoBH0JwGx1fEmTxRQ
oHl8WcFxJ2emv3ymo718RvC4ufQl835FQlJq7CGd7w2g7hYqTSBB/HZJUbe0i7OM
RCh7BYt4aN+Nw9ZV9ZBXb5A7E2rLAQq9Zit8coTspSPp5d94W9BDcq6tU1SUzFNK
hhw3bCEE2BPXft82d4ROqvchEFgeFT0f+/qvy50UW+XEYkvy9XE=
=/rkd
-----END PGP SIGNATURE-----

--k3qmt+ucFURmlhDS--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
