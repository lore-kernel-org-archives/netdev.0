From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next 3/3] tun: Fix copy/paste error in tun_get_user
Date: Sun, 7 Jun 2009 00:08:33 +0300
Message-ID: <20090606210833.GB28614@redhat.com>
References: <1244230546.1526.78.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:52282 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751881AbZFFVJ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Jun 2009 17:09:26 -0400
Content-Disposition: inline
In-Reply-To: <1244230546.1526.78.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 05, 2009 at 12:35:46PM -0700, Sridhar Samudrala wrote:
> Use the right structure while incrementing the offset in tun_get_user.
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 4cda69b..15cfcb2 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -567,7 +567,7 @@ static __inline__ ssize_t tun_get_user(struct
> tun_struct *tun,
> 
>  		if (gso.hdr_len > len)
>  			return -EINVAL;
> -		offset += sizeof(pi);
> +		offset += sizeof(gso);
>  	}
> 
>  	if ((tun->flags & TUN_TYPE_MASK) == TUN_TAP_DEV) {
> 

-- 
MST
