From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/11] Generalize the inet_diag infrastructure
Date: Tue, 06 Dec 2011 13:58:31 -0500 (EST)
Message-ID: <20111206.135831.2200580637009424398.davem@davemloft.net>
References: <4EDE573A.6040607@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60615 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751999Ab1LFS6f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 13:58:35 -0500
In-Reply-To: <4EDE573A.6040607@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Tue, 06 Dec 2011 21:56:10 +0400

> This is an attempt to prepare the existing inet_diag infrastructure to work with
> arbitrary address family and protocol pair, not only AF_INET(6) and TCP/DCCP.
> 
> This set adds the sock_diag infrastructure, that handles the new SOCK_DIAG_BY_FAMILY
> message type by the NETLINK_INET_DIAG socket. The core API struct for this (called
> sock_diag_req) contains two fields - family and type - which specify which sockets 
> to dump. Additional information is considered to be family handler specific.
> 
> The existing inet_diag code is patched to register himself inside the sock_diag and
> provide callbacks for dumping AF_INET/AF_INET6 IPPROTO_TCP/IPPROTO_DCCP sockets. The
> existing API facilities such as state filtering and bytecode is of course preserved
> and is treated by inet_diag specific data.
> 
> Binary compatibility with existing NETLINK_INET_DIAG is also kept.
> 
> No additional stuff in this set. The support for IPPROTO_UDP protocol and AF_UNIX
> family will come later if this set is approved.
> 
> Applies to net-next, patch for iproute2's ss tool (proving that the new code ... pretends
> to work) is at the end of the thread.
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

Applied, with the retention of a NETLINK_INET_DIAG define in patch #1 for
userspace compatability.
