From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 1/2] llc: fix non-const printk warning
Date: Fri, 20 Feb 2009 18:37:22 -0300
Message-ID: <20090220213722.GB18285@ghostprotocols.net>
References: <20090220100206.533d59d4@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:38820 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753357AbZBTViD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Feb 2009 16:38:03 -0500
Content-Disposition: inline
In-Reply-To: <20090220100206.533d59d4@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Fri, Feb 20, 2009 at 10:02:06AM -0800, Stephen Hemminger escreveu:
> Mark some strings as const.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Thanks,

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

> 
> --- a/net/llc/af_llc.c	2009-02-20 08:34:21.537870609 -0800
> +++ b/net/llc/af_llc.c	2009-02-20 08:37:52.920622312 -0800
> @@ -1118,11 +1118,11 @@ static const struct proto_ops llc_ui_ops
>  	.sendpage    = sock_no_sendpage,
>  };
>  
> -static char llc_proc_err_msg[] __initdata =
> +static const char llc_proc_err_msg[] __initconst =
>  	KERN_CRIT "LLC: Unable to register the proc_fs entries\n";
> -static char llc_sysctl_err_msg[] __initdata =
> +static const char llc_sysctl_err_msg[] __initconst =
>  	KERN_CRIT "LLC: Unable to register the sysctl entries\n";
> -static char llc_sock_err_msg[] __initdata =
> +static const char llc_sock_err_msg[] __initconst =
>  	KERN_CRIT "LLC: Unable to register the network family\n";
>  
>  static int __init llc2_init(void)
> --
