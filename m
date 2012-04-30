From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/10 net-next] l2tp: misc fixes and add L2TPv3 IP
 encap over IPv6
Date: Mon, 30 Apr 2012 13:46:37 -0400 (EDT)
Message-ID: <20120430.134637.1965477081443499316.davem@davemloft.net>
References: <1335772135-27910-1-git-send-email-jchapman@katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41040 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752968Ab2D3Rqn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 13:46:43 -0400
In-Reply-To: <1335772135-27910-1-git-send-email-jchapman@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Chapman <jchapman@katalix.com>
Date: Mon, 30 Apr 2012 08:48:45 +0100

> This patch series includes several L2TP fixes / cleanups and adds
> L2TPv3 IP encapsulation support for IPv6, building on the L2TP UDP
> IPv6 support recently added by Ben LaHaise.
> 
>   1. l2tp: fix locking of 64-bit counters for smp
>   2. l2tp: Use ip4_datagram_connect() in l2tp_ip_connect()
>   3. l2tp: remove unused stats from l2tp_ip socket
>   4. pppox: Replace __attribute__((packed)) in if_pppox.h
>   5. l2tp: pppol2tp_connect() handles ipv6 sockaddr variants
>   6. l2tp: show IPv6 addresses in l2tp debugfs file
>   7. l2tp: netlink api for l2tpv3 ipv6 unmanaged tunnels
>   8. ipv6: export ipv6 functions for use by other protocols
>   9. l2tp: introduce L2TPv3 IP encapsulation support for IPv6
>  10. l2tp: let iproute2 create L2TPv3 IP tunnels using IPv6
> 
> Patches 1-4 are fixes / cleanups.
> Patches 5-6 improve on the L2TP UDP IPv6 changes recently added.
> Patches 7-10 add functionality.
> 
> A patch for iproute2 to add support for unmanaged L2TPv3 ethernet
> tunnels over IPv6 will be submitted separately.

Series applied to net-next, thanks James.
