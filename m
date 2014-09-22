From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] udp: Need to make ip6_udp_tunnel.c have GPL
 license
Date: Mon, 22 Sep 2014 15:08:32 -0400 (EDT)
Message-ID: <20140922.150832.1458585102153232594.davem@davemloft.net>
References: <1411411184-11993-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: azhou@nicira.com, netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53004 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752740AbaIVTIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 15:08:34 -0400
In-Reply-To: <1411411184-11993-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 22 Sep 2014 11:39:44 -0700

> Unable to load various tunneling modules without this:
> 
> [   80.679049] fou: Unknown symbol udp_sock_create6 (err 0)
> [   91.439939] ip6_udp_tunnel: Unknown symbol ip6_local_out (err 0)
> [   91.439954] ip6_udp_tunnel: Unknown symbol __put_net (err 0)
> [   91.457792] vxlan: Unknown symbol udp_sock_create6 (err 0)
> [   91.457831] vxlan: Unknown symbol udp_tunnel6_xmit_skb (err 0)
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Applied, thanks Tom.
