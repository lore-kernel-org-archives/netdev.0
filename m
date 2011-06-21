From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] svcsock.c: include sunrpc.h to quite sparse noise
Date: Tue, 21 Jun 2011 18:44:18 -0400
Message-ID: <20110621224418.GB28047@fieldses.org>
References: <201106201754.51704.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, linux-nfs@vger.kernel.org,
	Trond.Myklebust@netapp.com, neilb@suse.de, davem@davemloft.net
To: H Hartley Sweeten <hartleys@visionengravers.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201106201754.51704.hartleys@visionengravers.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 20, 2011 at 05:54:51PM -0700, H Hartley Sweeten wrote:
> Include the private header sunrpc.h to pickup the declaration of the
> function svc_send_common to quiet the following sparse noise:
> 
> warning: symbol 'svc_send_common' was not declared. Should it be static?

Thanks, applying for 3.1--b.

> 
> Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
> Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: "J. Bruce Fields" <bfields@fieldses.org>
> Cc: Neil Brown <neilb@suse.de>
> Cc: "David S. Miller" <davem@davemloft.net>
> 
> ---
> 
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index af04f77..f2cb5b8 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -51,6 +51,8 @@
>  #include <linux/sunrpc/stats.h>
>  #include <linux/sunrpc/xprt.h>
>  
> +#include "sunrpc.h"
> +
>  #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
>  
>  
