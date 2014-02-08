From: Josh Triplett <josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org>
Subject: Re: [PATCH 13/13] net: Mark functions as static in
 net/sunrpc/svc_xprt.c
Date: Sat, 8 Feb 2014 12:23:55 -0800
Message-ID: <20140208202355.GA21612@leaf>
References: <6f029c895035908595957fb16ab445c82793c77d.1391888654.git.rashika.kheria@gmail.com>
 <259f3dc38d7115eccf3aaa2aa7de2414a47f90a2.1391888654.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Rashika Kheria <rashika.kheria-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <259f3dc38d7115eccf3aaa2aa7de2414a47f90a2.1391888654.git.rashika.kheria-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 09, 2014 at 01:40:54AM +0530, Rashika Kheria wrote:
> Mark functions as static in net/sunrpc/svc_xprt.c because they are no=
t
> used outside this file.
>=20
> This eliminates the following warning in net/sunrpc/svc_xprt.c:
> net/sunrpc/svc_xprt.c:574:5: warning: no previous prototype for =E2=80=
=98svc_alloc_arg=E2=80=99 [-Wmissing-prototypes]
> net/sunrpc/svc_xprt.c:615:18: warning: no previous prototype for =E2=80=
=98svc_get_next_xprt=E2=80=99 [-Wmissing-prototypes]
> net/sunrpc/svc_xprt.c:694:6: warning: no previous prototype for =E2=80=
=98svc_add_new_temp_xprt=E2=80=99 [-Wmissing-prototypes]
>=20
> Signed-off-by: Rashika Kheria <rashika.kheria-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Reviewed-by: Josh Triplett <josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org>

>  net/sunrpc/svc_xprt.c |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>=20
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index 80a6640..06c6ff0 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -571,7 +571,7 @@ static void svc_check_conn_limits(struct svc_serv=
 *serv)
>  	}
>  }
> =20
> -int svc_alloc_arg(struct svc_rqst *rqstp)
> +static int svc_alloc_arg(struct svc_rqst *rqstp)
>  {
>  	struct svc_serv *serv =3D rqstp->rq_server;
>  	struct xdr_buf *arg;
> @@ -612,7 +612,7 @@ int svc_alloc_arg(struct svc_rqst *rqstp)
>  	return 0;
>  }
> =20
> -struct svc_xprt *svc_get_next_xprt(struct svc_rqst *rqstp, long time=
out)
> +static struct svc_xprt *svc_get_next_xprt(struct svc_rqst *rqstp, lo=
ng timeout)
>  {
>  	struct svc_xprt *xprt;
>  	struct svc_pool		*pool =3D rqstp->rq_pool;
> @@ -691,7 +691,7 @@ struct svc_xprt *svc_get_next_xprt(struct svc_rqs=
t *rqstp, long timeout)
>  	return xprt;
>  }
> =20
> -void svc_add_new_temp_xprt(struct svc_serv *serv, struct svc_xprt *n=
ewxpt)
> +static void svc_add_new_temp_xprt(struct svc_serv *serv, struct svc_=
xprt *newxpt)
>  {
>  	spin_lock_bh(&serv->sv_lock);
>  	set_bit(XPT_TEMP, &newxpt->xpt_flags);
> --=20
> 1.7.9.5
>=20
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
