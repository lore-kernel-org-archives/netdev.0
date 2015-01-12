From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/16] tipc: make tipc support namespace
Date: Mon, 12 Jan 2015 16:24:59 -0500 (EST)
Message-ID: <20150112.162459.1011996139564111715.davem@davemloft.net>
References: <1420788433-17960-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Tero.Aho@coriant.com,
	Paul.Gortmaker@windriver.com, erik.hugne@ericsson.com,
	richard.alpe@ericsson.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54063 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752577AbbALVZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 16:25:04 -0500
In-Reply-To: <1420788433-17960-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Fri, 9 Jan 2015 15:26:57 +0800

> This patchset aims to add net namespace support for TIPC stack.
> 
> Currently TIPC module declares the following global resources:
> - TIPC network idenfication number
> - TIPC node table
> - TIPC bearer list table
> - TIPC broadcast link
> - TIPC socket reference table
> - TIPC name service table
> - TIPC node address
> - TIPC service subscriber server
> - TIPC random value
> - TIPC netlink
> 
> In order that TIPC is aware of namespace, above each resource must be
> allocated, initialized and destroyed inside per namespace. Therefore,
> the major works of this patchset are to isolate these global resources
> and make them private for each namespace. However, before these changes
> come true, some necessary preparation works must be first done: convert
> socket reference table with generic rhashtable, cleanup core.c and
> core.h files, remove unnecessary wrapper functions for kernel timer
> interfaces and so on.
> 
> It should be noted that commit ##1 ("tipc: fix bug in broadcast
> retransmit code") was already submitted to 'net' tree, so please see
> below link:
> 
> http://patchwork.ozlabs.org/patch/426717/
> 
> Since it is prerequisite for the rest of the series to apply, I
> prepend them to the series.

Series applied, thank you.
