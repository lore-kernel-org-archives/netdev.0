From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] [IPV6]: Policy Routing Rules
Date: Wed, 26 Jul 2006 16:26:30 -0700 (PDT)
Message-ID: <20060726.162630.73380024.davem@davemloft.net>
References: <20060726221100.325687073@postel.suug.ch>
	<20060726221850.124450582@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vnuorval@tcs.hut.fi,
	usagi-core@linux-ipv6.org, yoshfuji@linux-ipv6.org,
	anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:51900
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751260AbWGZX0Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jul 2006 19:26:24 -0400
To: tgraf@suug.ch
In-Reply-To: <20060726221850.124450582@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 27 Jul 2006 00:00:04 +0200

> Index: net-2.6.git/net/ipv6/Makefile
> ===================================================================
> --- net-2.6.git.orig/net/ipv6/Makefile
> +++ net-2.6.git/net/ipv6/Makefile
> @@ -29,3 +29,5 @@ obj-$(CONFIG_IPV6_TUNNEL) += ip6_tunnel.
>  obj-y += exthdrs_core.o
>  
>  obj-$(subst m,y,$(CONFIG_IPV6)) += inet6_hashtables.o
> +
> +obj-$(CONFIG_IPV6_MULTIPLE_TABLES) += fib6_rules.o

This will cause a build failure if IPV6 is built modular.

The fix is simple, make CONFIG_IPV6_MULTIPLE_TABLES
a tristate instead of a bool.
