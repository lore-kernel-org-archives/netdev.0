From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] ipgre: follow state of lower device
Date: Sat, 14 Apr 2012 14:53:02 -0400 (EDT)
Message-ID: <20120414.145302.154475725141872738.davem@davemloft.net>
References: <20120412163115.076119065@vyatta.com>
	<20120412163142.544953001@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59432 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755366Ab2DNSxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Apr 2012 14:53:04 -0400
In-Reply-To: <20120412163142.544953001@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 12 Apr 2012 09:31:17 -0700

> GRE tunnels like other layered devices should propogate
> carrier and RFC2863 state from lower device to tunnel.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Like others I don't like the ugly hash traversal.

A small hash on ifindex, iflink, or whatever ought to be easy and make
the code look much nicer.

Longer term project is that a lot of this tunneling code can be
commonized at some point.
