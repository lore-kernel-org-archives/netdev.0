From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-next patch] vxlan: remove unused variable.
Date: Sat, 17 Nov 2012 09:52:25 -0800
Message-ID: <20121117095225.48bd9ab1@nehalam.linuxnetplumber.net>
References: <1353161287-22493-1-git-send-email-ramirose@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Rami Rosen <ramirose@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33438 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751765Ab2KQRx3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Nov 2012 12:53:29 -0500
In-Reply-To: <1353161287-22493-1-git-send-email-ramirose@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 17 Nov 2012 16:08:07 +0200
Rami Rosen <ramirose@gmail.com> wrote:

> This patch removes addrexceeded member from vxlan_dev struct as it is unused.
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>
> ---
>  drivers/net/vxlan.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 9814d67..288ad3a 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -117,7 +117,6 @@ struct vxlan_dev {
>  	spinlock_t	  hash_lock;
>  	unsigned int	  addrcnt;
>  	unsigned int	  addrmax;
> -	unsigned int	  addrexceeded;
>  
>  	struct hlist_head fdb_head[FDB_HASH_SIZE];
>  };

Acked-by: Stephen Hemminger <shemminger@vyatta.com>
