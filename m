From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [2.6 patch] net/ipv6/: misc possible cleanups
Date: Wed, 15 Dec 2004 10:59:00 +0900 (JST)
Message-ID: <20041215.105900.27736391.yoshfuji@linux-ipv6.org>
References: <20041215005546.GA11972@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: bunk@stusta.de
In-Reply-To: <20041215005546.GA11972@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20041215005546.GA11972@stusta.de> (at Wed, 15 Dec 2004 01:55:46 +0100), Adrian Bunk <bunk@stusta.de> says:

> The patch below contains the following possible cleanups:
> - make some needlessly global code static
> - remove the following unused functions:
>   - exthdrs.c: ipv6_build_rthdr
>   - exthdrs.c: ipv6_build_exthdr
>   - exthdrs.c: ipv6_build_nfrag_opts
>   - exthdrs.c: ipv6_build_frag_opts
> - remove the following unused global variables:
>   - addrconf.c: in6addr_any
> - remove the following EXPORT_SYMBOL's:
>   - ipv6_syms.c: addrconf_lock
>   - ipv6_syms.c: in6addr_any
>   - ipv6_syms.c: in6addr_loopback
> 
> Please comment on which of these changes are correct and which conflict
> with pending patches.

Please keep addrconf_lock (for SCTP).
Please keep in6addr_any in addrconf.c (or enclose by #if 0 ... #endif)

> --- linux-2.6.10-rc3-mm1-full/include/net/ip.h.old	2004-12-14 05:20:46.000000000 +0100
> +++ linux-2.6.10-rc3-mm1-full/include/net/ip.h	2004-12-14 05:20:53.000000000 +0100
:

I think you attatched incorrect patch file.

--yoshfuji
