From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [RFC] Vegas and tcp parameters per route
Date: Tue, 16 Mar 2004 02:38:32 +0900 (JST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040316.023832.02446886.yoshfuji@linux-ipv6.org>
References: <20040312151729.25d9c696@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com, linux-net@vger.kernel.org,
	yoshfuji@linux-ipv6.org
Return-path: <linux-net-owner@vger.kernel.org>
To: shemminger@osdl.org
In-Reply-To: <20040312151729.25d9c696@dell_ss3.pdx.osdl.net>
List-Id: netdev.vger.kernel.org

In article <20040312151729.25d9c696@dell_ss3.pdx.osdl.net> (at Fri, 12 Mar 2004 15:17:29 -0800), Stephen Hemminger <shemminger@osdl.org> says:

> diff -urNp -X dontdiff linux-2.6/include/linux/sysctl.h tcp-vegas-2.6/include/linux/sysctl.h
> --- linux-2.6/include/linux/sysctl.h	2004-03-09 16:24:23.000000000 -0800
> +++ tcp-vegas-2.6/include/linux/sysctl.h	2004-03-12 14:20:25.000000000 -0800
> @@ -317,11 +317,12 @@ enum
>  	NET_IPV4_ICMP_RATELIMIT=89,
>  	NET_IPV4_ICMP_RATEMASK=90,
>  	NET_TCP_TW_REUSE=91,
> -	NET_TCP_FRTO=92,
> -	NET_TCP_LOW_LATENCY=93,
> -	NET_IPV4_IPFRAG_SECRET_INTERVAL=94,
> -	NET_TCP_WESTWOOD=95,
> -	NET_IPV4_IGMP_MAX_MSF=96,
> +	NET_TCP_LOW_LATENCY=92,
> +	NET_IPV4_IPFRAG_SECRET_INTERVAL=93,
> +	NET_IPV4_IGMP_MAX_MSF=94,
> +	NET_TCP_VEGAS_ALPHA=95,
> +	NET_TCP_VEGAS_BETA=96,
> +	NET_TCP_VEGAS_GAMMA=97,
>  };
>  

Please do not change values for NET_IPV4_IPFRAG_SECRET_INTERVAL etc.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
