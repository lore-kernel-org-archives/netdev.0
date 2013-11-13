From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH] svcrpc: remove the unnecessary evaluation
Date: Wed, 13 Nov 2013 10:56:58 -0500
Message-ID: <20131113155658.GH28033@fieldses.org>
References: <52786417.6090707@huawei.com>
 <527C9160.3070808@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: Weng Meiling <wengmeiling.weng-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <527C9160.3070808-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 08, 2013 at 03:23:12PM +0800, Weng Meiling wrote:
> 
> From: Weng Meiling <wengmeiling.weng-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

Huh.  Looks like that was introduced with "[PATCH] knfsd: make sure
svc_process call the correct pg_authenticate for multi-service port" in
2005.  OK!  Applied.

--b.

> 
> Signed-off-by: Weng Meiling <wengmeiling.weng-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> ---
>  net/sunrpc/svc.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index b974571..e7fbe36 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -1104,8 +1104,6 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
>  	rqstp->rq_vers = vers = svc_getnl(argv);	/* version number */
>  	rqstp->rq_proc = proc = svc_getnl(argv);	/* procedure number */
> 
> -	progp = serv->sv_program;
> -
>  	for (progp = serv->sv_program; progp; progp = progp->pg_next)
>  		if (prog == progp->pg_prog)
>  			break;
> -- 
> 1.8.3.1
> 
> 
> 
> 
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
