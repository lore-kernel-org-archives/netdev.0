From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] udp_tunnel: Only build ip6_udp_tunnel.c when IPV6
 is selected
Date: Fri, 19 Sep 2014 22:06:20 -0400 (EDT)
Message-ID: <20140919.220620.557633612726378260.davem@davemloft.net>
References: <1411174973-323-1-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: azhou@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32912 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755919AbaITCGW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 22:06:22 -0400
In-Reply-To: <1411174973-323-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Zhou <azhou@nicira.com>
Date: Fri, 19 Sep 2014 18:02:53 -0700

> Functions supplied in ip6_udp_tunnel.c are only needed when IPV6 is
> selected. When IPV6 is not selected, those functions are stubbed out
> in udp_tunnel.h.
> 
> ==================================================================
>  net/ipv6/ip6_udp_tunnel.c:15:5: error: redefinition of 'udp_sock_create6'
>      int udp_sock_create6(struct net *net, struct udp_port_cfg *cfg,
>  In file included from net/ipv6/ip6_udp_tunnel.c:9:0:
>       include/net/udp_tunnel.h:36:19: note: previous definition of 'udp_sock_create6' was here
>        static inline int udp_sock_create6(struct net *net, struct udp_port_cfg *cfg,
> ==================================================================
> 
> Fixes:  fd384412e udp_tunnel: Seperate ipv6 functions into its own file
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Andy Zhou <azhou@nicira.com>

Applied, thanks Andy.
