From: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] net: fix htmldocs sunrpc, clnt.c
Date: Thu, 24 Sep 2009 09:19:35 -0700
Message-ID: <4ABB9C17.3020307@oracle.com>
References: <1253794781.5860.29.camel@ht.satnam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ricardo Labiaga <Ricardo.Labiaga-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	Benny Halevy <bhalevy-C4P08NqkoRlBDgjK7y7TUQ@public.gmane.org>,
	Andy Adamson <andros-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jaswinder Singh Rajput <jaswinder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1253794781.5860.29.camel-6Ww87KsxWewAvxtiuMwx3w@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Jaswinder Singh Rajput wrote:
>   DOCPROC Documentation/DocBook/networking.xml
>   Warning(net/sunrpc/clnt.c:647): No description found for parameter 'req'
>   Warning(net/sunrpc/clnt.c:647): No description found for parameter 'tk_ops'
>   Warning(net/sunrpc/clnt.c:647): Excess function parameter 'ops' description in 'rpc_run_bc_task'
> 
> Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Ack.  Already sent, but possibly lost.

> Cc: Ricardo Labiaga <Ricardo.Labiaga-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
> Cc: Benny Halevy <bhalevy-C4P08NqkoRlBDgjK7y7TUQ@public.gmane.org>
> Cc: Andy Adamson <andros-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
> Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
> Cc: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> ---
>  net/sunrpc/clnt.c |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index a417d5a..38829e2 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -640,10 +640,11 @@ EXPORT_SYMBOL_GPL(rpc_call_async);
>  /**
>   * rpc_run_bc_task - Allocate a new RPC task for backchannel use, then run
>   * rpc_execute against it
> - * @ops: RPC call ops
> + * @req: RPC request
> + * @tk_ops: RPC call ops
>   */
>  struct rpc_task *rpc_run_bc_task(struct rpc_rqst *req,
> -					const struct rpc_call_ops *tk_ops)
> +				const struct rpc_call_ops *tk_ops)
>  {
>  	struct rpc_task *task;
>  	struct xdr_buf *xbufp = &req->rq_snd_buf;

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
