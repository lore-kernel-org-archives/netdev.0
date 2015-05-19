From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv6/udp: Fix ipv6 multicast socket filter
 regression
Date: Tue, 19 May 2015 16:35:27 -0400 (EDT)
Message-ID: <20150519.163527.1773026813864217682.davem@davemloft.net>
References: <1431976129-28032-1-git-send-email-hrogge@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hrogge@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47915 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751322AbbESUf3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 16:35:29 -0400
In-Reply-To: <1431976129-28032-1-git-send-email-hrogge@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Henning Rogge <hrogge@gmail.com>
Date: Mon, 18 May 2015 21:08:49 +0200

> Commit <5cf3d46192fc> ("udp: Simplify__udp*_lib_mcast_deliver")
> simplified the filter for incoming IPv6 multicast but removed
> the check of the local socket address and the UDP destination
> address.
> 
> This patch restores the filter to prevent sockets bound to a IPv6
> multicast IP to receive other UDP traffic link unicast.
> 
> Signed-off-by: Henning Rogge <hrogge@gmail.com>
> Fixes: 5cf3d46192fc ("udp: Simplify__udp*_lib_mcast_deliver")

Applied and queued up for -stable, thanks.
