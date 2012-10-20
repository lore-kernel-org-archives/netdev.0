From: Serge Hallyn <serge.hallyn@canonical.com>
Subject: Re: [PATCH 1/1] [PATCH net-next] net:dev: remove double indentical
 assignment in dev_change_net_namespace().
Date: Fri, 19 Oct 2012 19:07:56 -0500
Message-ID: <20121020000756.GA29345@sergelap>
References: <1350644970-2877-1-git-send-email-ramirose@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Rami Rosen <ramirose@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:35276 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754972Ab2JTAID (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2012 20:08:03 -0400
Content-Disposition: inline
In-Reply-To: <1350644970-2877-1-git-send-email-ramirose@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Rami Rosen (ramirose@gmail.com):
> This patch removes double assignment of err to -EINVAL in dev_change_net_namespace().
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Yup, sure is a duplicate assignment...

Acked-by: Serge E. Hallyn <serge.hallyn@ubuntu.com>

> ---
>  net/core/dev.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 09cb3f6..b4978e2 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -6264,7 +6264,6 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
>  		goto out;
>  
>  	/* Ensure the device has been registrered */
> -	err = -EINVAL;
>  	if (dev->reg_state != NETREG_REGISTERED)
>  		goto out;
>  
> -- 
> 1.7.11.4
> 
