From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] allow nf_tproxy_core module to unload
Date: Fri, 18 Dec 2009 19:41:46 -0800 (PST)
Message-ID: <20091218.194146.104066031.davem@davemloft.net>
References: <20091218162440.22480.3383.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sassmann@redhat.com,
	netfilter-devel@vger.kernel.org
To: emcnabb@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39618
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753210AbZLSDlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 22:41:45 -0500
In-Reply-To: <20091218162440.22480.3383.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Evan McNabb <emcnabb@redhat.com>
Date: Fri, 18 Dec 2009 11:24:40 -0500

> From: Evan McNabb <emcnabb@redhat.com>
> 
> Include exit function so nf_tproxy_core module can be removed.
> 
> Signed-off-by: Evan McNabb <emcnabb@redhat.com>

netfilter-devel is the best place to CC: netfilter
patches, added...

> 
> diff --git a/net/netfilter/nf_tproxy_core.c b/net/netfilter/nf_tproxy_core.c
> index 5490fc3..ec6737c 100644
> --- a/net/netfilter/nf_tproxy_core.c
> +++ b/net/netfilter/nf_tproxy_core.c
> @@ -89,7 +89,12 @@ static int __init nf_tproxy_init(void)
>  	return 0;
>  }
>  
> +static void __exit nf_tproxy_exit(void)
> +{
> +}
> +
>  module_init(nf_tproxy_init);
> +module_exit(nf_tproxy_exit);
>  
>  MODULE_LICENSE("GPL");
>  MODULE_AUTHOR("Krisztian Kovacs");
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
