From: David Miller <davem@davemloft.net>
Subject: Re: [v8 net-next 0/4] Refactor vxlan and l2tp to use new common
 UDP tunnel APIs
Date: Fri, 19 Sep 2014 15:58:03 -0400 (EDT)
Message-ID: <20140919.155803.345709375375891169.davem@davemloft.net>
References: <1410913787-31599-1-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: azhou@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58667 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932080AbaIST6F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 15:58:05 -0400
In-Reply-To: <1410913787-31599-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Zhou <azhou@nicira.com>
Date: Tue, 16 Sep 2014 17:29:43 -0700

> This patch series add a few more UDP tunnel APIs and refactoring current
> UDP tunnel based protocols, vxlan and l2tp to make use of the new APIs.
> 
> The added APIs are setup_udp_tunnel_sock(), udp_tunnel_xmit_skb() and 
> udp_tunnel_sock_release(). Those implementation logics already exist in
> current vxlan and l2tp implementation. Move them to common APIs to reduce
> code duplications.
> 
> Also split udp_tunnel.c into net/ipv4/udp_tunnel.c and
> net/ipv6/ip6_udp_tunnel.c to maintain proper IP protocol separation.

Series applied, thanks.
