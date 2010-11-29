From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 1/3] net: kill unused macros in head file
Date: Mon, 29 Nov 2010 16:42:43 +0900
Message-ID: <1291016563.7802.2.camel@takos>
References: <4CF34DEC.6090907@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Network-Maillist <netdev@vger.kernel.org>, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org,
	Patrick McHardy <kaber@trash.net>, yoshfuji@linux-ipv6.org
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:34000 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754600Ab0K2Htz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 02:49:55 -0500
In-Reply-To: <4CF34DEC.6090907@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010-11-29 14:53 +0800, Shan Wei wrote:
> These macros have been defined for several years since v2.6.12-rc2（tracing by git）,
> but never be used. So remove them.
> 
> 
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
> ---
>  include/net/addrconf.h  |    2 --
>  include/net/ip6_route.h |    1 -
>  include/net/ndisc.h     |    6 ------
>  include/net/snmp.h      |    1 -
>  include/net/sock.h      |    3 ---
>  include/net/tcp.h       |    6 ------
>  6 files changed, 0 insertions(+), 19 deletions(-)
> 
> diff --git a/include/net/addrconf.h b/include/net/addrconf.h
> index a944124..23710aa 100644
> --- a/include/net/addrconf.h
> +++ b/include/net/addrconf.h
> @@ -1,8 +1,6 @@
>  #ifndef _ADDRCONF_H
>  #define _ADDRCONF_H
>  
> -#define RETRANS_TIMER	HZ
> -
>  #define MAX_RTR_SOLICITATIONS		3
>  #define RTR_SOLICITATION_INTERVAL	(4*HZ)
>  

I think we should use it in net/ipv6/addrconf.c,
instead of magic number.

> diff --git a/include/net/ndisc.h b/include/net/ndisc.h
> index 895997b..f134987 100644
> --- a/include/net/ndisc.h
> +++ b/include/net/ndisc.h
> @@ -39,12 +39,6 @@ enum {
>  
>  #define MAX_RTR_SOLICITATION_DELAY	HZ
>  
> -#define ND_REACHABLE_TIME		(30*HZ)
> -#define ND_RETRANS_TIMER		HZ

ditto (in net/ipv6/ndisc.c)

--yoshfuji

