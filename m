From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2.6]: IPv4: strcpy -> strlcpy
Date: Fri, 28 Nov 2003 11:05:25 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031128.110525.113293143.yoshfuji@linux-ipv6.org>
References: <20031127142125.GG8276@jdj5.mit.edu>
	<3FC67128.14704.30155D53@localhost>
	<1069970946.2138.13.camel@teapot.felipe-alfaro.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timo@kamph.org, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        davem@redhat.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: felipe_alfaro@linuxmail.org
In-Reply-To: <1069970946.2138.13.camel@teapot.felipe-alfaro.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <1069970946.2138.13.camel@teapot.felipe-alfaro.com> (at Thu, 27 Nov 2003 23:09:06 +0100), Felipe Alfaro Solana <felipe_alfaro@linuxmail.org> says:

> diff -uNr linux-2.6.0-test11.orig/net/ipv4/ipconfig.c linux-2.6.0-test11/net/ipv4/ipconfig.c
> --- linux-2.6.0-test11.orig/net/ipv4/ipconfig.c	2003-11-26 21:42:55.000000000 +0100
> +++ linux-2.6.0-test11/net/ipv4/ipconfig.c	2003-11-27 13:32:06.904650818 +0100
> @@ -299,7 +299,7 @@
>  	int err;
>  
>  	memset(&ir, 0, sizeof(ir));
> -	strcpy(ir.ifr_ifrn.ifrn_name, ic_dev->name);
> +	strlcpy(ir.ifr_ifrn.ifrn_name, ic_dev->name, sizeof(ir.ifr_ifrn.ifrn_name));

please use
	strlcpy(ir.ifr_name, ic_dev->name, sizeof(ir.ifr_name));
instead.

--yoshfuji
