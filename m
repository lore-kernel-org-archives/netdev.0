From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: introduce new IP_MTU_DISCOVER mode
 IP_PMTUDISC_INTERFACE
Date: Thu, 31 Oct 2013 00:29:11 -0400 (EDT)
Message-ID: <20131031.002911.1316728367651608156.davem@davemloft.net>
References: <20131030200725.GB9093@order.stressinduktion.org>
	<20131030.173608.2156276556221568210.davem@davemloft.net>
	<20131030225851.GB13902@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fweimer@redhat.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36699 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779Ab3JaE3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Oct 2013 00:29:12 -0400
In-Reply-To: <20131030225851.GB13902@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 30 Oct 2013 23:58:51 +0100

> DNS resolver can fallback to TCP for querying where we can honour the
> path MTU because it won't do any harm and ensures connectivity.
> 
> Also for TCP the socket is matched on the whole 4-tuple and we may
> fallback to a 2-tuple lookup on unconnected UDP sockets. The new socket
> option would let an application programmer choose to do path mtu discovery
> because it knows it will only use a connected socket. On unconnected
> sockets one can specify IP_PMTUDISC_INTERFACE to suppress the path MTU
> updates and always use the interface MTU without the DF-bit set.

This still sounds like a route scope policy with two binary states,
one for connected sockets and one for unconnected ones.
