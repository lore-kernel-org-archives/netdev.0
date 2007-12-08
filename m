From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH][NET]: Finish removing unused "mibalign" argument for
 snmp_mib_init().
Date: Sat, 08 Dec 2007 10:13:54 -0800 (PST)
Message-ID: <20071208.101354.18036989.yoshfuji@linux-ipv6.org>
References: <20071208.004128.44758266.yoshfuji@linux-ipv6.org>
	<20071208.004147.99843986.davem@davemloft.net>
	<20071208175532.GE3180@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: acme@redhat.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:43068 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751054AbXLHSNc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Dec 2007 13:13:32 -0500
In-Reply-To: <20071208175532.GE3180@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

In article <20071208175532.GE3180@ghostprotocols.net> (at Sat, 8 Dec 2007 15:55:34 -0200), Arnaldo Carvalho de Melo <acme@redhat.com> says:

> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
> 
> diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
> index 5ab8ba7..90d2f72 100644
> --- a/net/ipv6/af_inet6.c
> +++ b/net/ipv6/af_inet6.c
> @@ -714,20 +714,19 @@ EXPORT_SYMBOL_GPL(ipv6_opt_accepted);
>  
>  static int __init init_ipv6_mibs(void)
>  {
> -	if (snmp_mib_init((void **)ipv6_statistics, sizeof (struct ipstats_mib),
> -			  __alignof__(struct ipstats_mib)) < 0)
> +	if (snmp_mib_init((void **)ipv6_statistics,
> +			  sizeof(struct ipstats_mib)) < 0)
>  		goto err_ip_mib;

Oops... thanks.
Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--yoshfuji
