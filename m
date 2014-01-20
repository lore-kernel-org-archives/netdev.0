From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: make IPV6_RECVPKTINFO work for ipv4
 datagrams
Date: Sun, 19 Jan 2014 19:53:30 -0800 (PST)
Message-ID: <20140119.195330.222470459722415835.davem@davemloft.net>
References: <20140120024308.GE16462@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gert@space.net
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41047 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752430AbaATDxb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jan 2014 22:53:31 -0500
In-Reply-To: <20140120024308.GE16462@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 20 Jan 2014 03:43:08 +0100

> We currently don't report IPV6_RECVPKTINFO in cmsg access ancillary data
> for IPv4 datagrams on IPv6 sockets.
> 
> This patch splits the ip6_datagram_recv_ctl into two functions, one
> which handles both protocol families, AF_INET and AF_INET6, while the
> ip6_datagram_recv_specific_ctl only handles IPv6 cmsg data.
> 
> ip6_datagram_recv_*_ctl never reported back any errors, so we can make
> them return void. Also provide a helper for protocols which don't offer dual
> personality to further use ip6_datagram_recv_ctl, which is exported to
> modules.
> 
> I needed to shuffle the code for ping around a bit to make it easier to
> implement dual personality for ping ipv6 sockets in future.
> 
> Reported-by: Gert Doering <gert@space.net>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Looks good, applied, thanks.
