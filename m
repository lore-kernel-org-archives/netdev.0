From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] openvswitch: fix a compilation error when
 CONFIG_INET is not setW!
Date: Tue, 07 Oct 2014 00:11:23 -0400 (EDT)
Message-ID: <20141007.001123.407556403373178636.davem@davemloft.net>
References: <1412633714-25048-1-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: azhou@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40863 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752528AbaJGELY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 00:11:24 -0400
In-Reply-To: <1412633714-25048-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Zhou <azhou@nicira.com>
Date: Mon,  6 Oct 2014 15:15:14 -0700

> Fix a openvswitch compilation error when CONFIG_INET is not set:
> 
> =====================================================
>    In file included from include/net/geneve.h:4:0,
>                        from net/openvswitch/flow_netlink.c:45:
> 		          include/net/udp_tunnel.h: In function 'udp_tunnel_handle_offloads':
> 			  >> include/net/udp_tunnel.h:100:2: error: implicit declaration of function 'iptunnel_handle_offloads' [-Werror=implicit-function-declaration]
> 			  >>      return iptunnel_handle_offloads(skb, udp_csum, type);
> 			  >>           ^
> 			  >>           >> include/net/udp_tunnel.h:100:2: warning: return makes pointer from integer without a cast
> 			  >>           >>    cc1: some warnings being treated as errors
> 
> =====================================================
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Andy Zhou <azhou@nicira.com>

Applied.
