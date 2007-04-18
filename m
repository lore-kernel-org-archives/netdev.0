From: Pavel Emelianov <xemul@sw.ru>
Subject: Re: [BRIDGE] Unaligned access on IA64 when comparing ethernet addresses
Date: Wed, 18 Apr 2007 10:43:56 +0400
Message-ID: <4625BE2C.1030801@sw.ru>
References: <4624B44A.9040509@sw.ru>	<20070417.123135.56861973.davem@davemloft.net>	<4625263D.1000709@linux-foundation.org>	<20070417.130929.59470175.davem@davemloft.net> <20070417133723.00031f82@mini>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	bridge@lists.osdl.org, devel@openvz.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:23654 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752016AbXDRGjL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Apr 2007 02:39:11 -0400
In-Reply-To: <20070417133723.00031f82@mini>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[snip]

> --- linux-2.6.orig/net/bridge/br_private.h	2007-04-17
> 13:26:48.000000000 -0700 +++ linux-2.6/net/bridge/br_private.h
> 2007-04-17 13:30:29.000000000 -0700 @@ -36,7 +36,7 @@
>  {
>  	unsigned char	prio[2];
>  	unsigned char	addr[6];
> -};
> +} __attribute__((aligned(8)));

Why "8"? Mustn't it be "16"? Address is to be 2-bytes aligned...

>  struct mac_addr
>  {
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

