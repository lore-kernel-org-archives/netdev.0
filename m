From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] Make XFRM optional
Date: Mon, 04 Aug 2003 21:58:01 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030804.215801.124854897.yoshfuji@linux-ipv6.org>
References: <20030804125022.GA8167@averell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: ak@muc.de
In-Reply-To: <20030804125022.GA8167@averell>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

In article <20030804125022.GA8167@averell> (at Mon, 4 Aug 2003 14:50:22 +0200), Andi Kleen <ak@muc.de> says:

> diff -u linux-work/net/ipv6/Kconfig-XFRM linux-work/net/ipv6/Kconfig
> --- linux-work/net/ipv6/Kconfig-XFRM	2003-07-18 02:39:29.000000000 +0200
> +++ linux-work/net/ipv6/Kconfig	2003-08-03 23:12:25.000000000 +0200
> @@ -4,6 +4,7 @@
>  config IPV6_PRIVACY
>  	bool "IPv6: Privacy Extensions (RFC 3041) support"
>  	depends on IPV6
> +	select XFRM
>  	select CRYPTO
>  	select CRYPTO_MD5
>  	---help---

We do not need this.

> @@ -57,6 +61,7 @@
>  
>  config IPV6_TUNNEL
>  	tristate "IPv6: IPv6-in-IPv6 tunnel"
> +	select XFRM
>  	depends on IPV6
>  	---help---
>  	  Support for IPv6-in-IPv6 tunnels described in RFC 2473.

We do not need this for now.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
