From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-2.6.25 1/6][CORE] Remove unneeded ifdefs from sysctl_net_core.c
Date: Sat, 01 Dec 2007 19:05:37 -0700
Message-ID: <m1tzn13l72.fsf@ebiederm.dsl.xmission.com>
References: <47515A29.3070806@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:55534 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753784AbXLBCHJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 21:07:09 -0500
In-Reply-To: <47515A29.3070806@openvz.org> (Pavel Emelyanov's message of "Sat,
	01 Dec 2007 15:57:13 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov <xemul@openvz.org> writes:

> They include the whole file, but it is already compiled
> out when SYSCTL=n, since it is obj-$(CONFIG_SYSCTL) target
> in the Makefile.

Pavel thanks for sending these patches.  Might I ask
for some level of acknowledgement when you rework one of
my patches and send it off.

I suppose this could be a case of duplicate thinking but
this patch looks very familiar.

Eric


> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
>
> ---
>
> diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
> index 113cc72..277c8fa 100644
> --- a/net/core/sysctl_net_core.c
> +++ b/net/core/sysctl_net_core.c
> @@ -13,8 +13,6 @@
>  #include <net/sock.h>
>  #include <net/xfrm.h>
>  
> -#ifdef CONFIG_SYSCTL
> -
>  ctl_table core_table[] = {
>  #ifdef CONFIG_NET
>  	{
> @@ -151,5 +149,3 @@ ctl_table core_table[] = {
>  	},
>  	{ .ctl_name = 0 }
>  };
> -
> -#endif
> -- 
> 1.5.3.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
