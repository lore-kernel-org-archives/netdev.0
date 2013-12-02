From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] sunrpc: fix some typos
Date: Mon, 2 Dec 2013 09:51:01 -0500
Message-ID: <20131202145101.GE1960@fieldses.org>
References: <5299B65C.4070700@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Trond.Myklebust@netapp.com,
	davem@davemloft.net, Li Zefan <lizefan@huawei.com>,
	Huang Qiang <h.huangqiang@huawei.com>
To: Weng Meiling <wengmeiling.weng@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5299B65C.4070700@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks, applying.--b.

On Sat, Nov 30, 2013 at 05:56:44PM +0800, Weng Meiling wrote:
> 
> From: Weng Meiling <wengmeiling.weng@huawei.com>
> 
> Signed-off-by: Weng Meiling <wengmeiling.weng@huawei.com>
> ---
>  include/linux/sunrpc/svc.h | 2 +-
>  net/sunrpc/xprtsock.c      | 7 +++----
>  2 files changed, 4 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> index 6eecfc2..b6316423 100644
> --- a/include/linux/sunrpc/svc.h
> +++ b/include/linux/sunrpc/svc.h
> @@ -368,7 +368,7 @@ struct svc_program {
>  	struct svc_program *	pg_next;	/* other programs (same xprt) */
>  	u32			pg_prog;	/* program number */
>  	unsigned int		pg_lovers;	/* lowest version */
> -	unsigned int		pg_hivers;	/* lowest version */
> +	unsigned int		pg_hivers;	/* highest version */
>  	unsigned int		pg_nvers;	/* number of versions */
>  	struct svc_version **	pg_vers;	/* version array */
>  	char *			pg_name;	/* service name */
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index dd9d295..0f4f391 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -2932,10 +2932,9 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
> 
>  	/*
>  	 * Once we've associated a backchannel xprt with a connection,
> -	 * we want to keep it around as long as long as the connection
> -	 * lasts, in case we need to start using it for a backchannel
> -	 * again; this reference won't be dropped until bc_xprt is
> -	 * destroyed.
> +	 * we want to keep it around as long as the connection lasts,
> +	 * in case we need to start using it for a backchannel again;
> +	 * this reference won't be dropped until bc_xprt is destroyed.
>  	 */
>  	xprt_get(xprt);
>  	args->bc_xprt->xpt_bc_xprt = xprt;
> -- 
> 1.8.3
> 
> 
