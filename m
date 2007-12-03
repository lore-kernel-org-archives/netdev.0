From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 2.6.25] net: removes unnecessary dependencies for net_namespace.h
Date: Mon, 03 Dec 2007 04:56:01 -0700
Message-ID: <m1odd80z72.fsf@ebiederm.dsl.xmission.com>
References: <20071203091200.GA20442@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, devel@openvz.org,
	netdev@vger.kernel.org, davem@davemloft.net, xemul@openvz.org
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:36815 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751531AbXLCL5g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2007 06:57:36 -0500
In-Reply-To: <20071203091200.GA20442@iris.sw.ru> (Denis V. Lunev's message of
	"Mon, 3 Dec 2007 12:12:00 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Denis V. Lunev" <den@openvz.org> writes:

> This patch removes some unneeded includes for net_namespace.h to speed up
> compilation.
>
> Signed-off-by: Denis V. Lunev <den@openvz.org>
>
> diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
> index f285de6..28b7f25 100644
> --- a/include/net/pkt_cls.h
> +++ b/include/net/pkt_cls.h
> @@ -2,7 +2,6 @@
>  #define __NET_PKT_CLS_H
>  
>  #include <linux/pkt_cls.h>
> -#include <net/net_namespace.h>
>  #include <net/sch_generic.h>
>  #include <net/act_api.h>

What of tcf_match_indev?  I guess linux/netdevice.h brings
it in for us but still.

> diff --git a/include/net/sock.h b/include/net/sock.h
> index 43e3cd9..a04e361 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -57,7 +57,6 @@
>  #include <asm/atomic.h>
>  #include <net/dst.h>
>  #include <net/checksum.h>
> -#include <net/net_namespace.h>
>  
>  /*
>   * This structure really needs to be cleaned up.
> @@ -95,6 +94,7 @@ typedef struct {
>  
>  struct sock;
>  struct proto;
> +struct net;
>  
>  /**
>   *	struct sock_common - minimal network layer representation of sockets

This hunk definitely looks sane.

Eric

