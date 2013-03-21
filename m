From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] Get rid of attribute parsing in
 rtnetlink_rcv_msg()
Date: Thu, 21 Mar 2013 15:19:01 -0400 (EDT)
Message-ID: <20130321.151901.586254173559160329.davem@davemloft.net>
References: <cover.1363885020.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46081 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751265Ab3CUTTD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 15:19:03 -0400
In-Reply-To: <cover.1363885020.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 21 Mar 2013 18:45:27 +0100

> We have been wanting to get rid of rta_buf for a while. It is error
> prone as it requires subsystems, especially modules, that register a
> rtnetlink mesage type to also modify rtnetlink.c and thus require
> the recompilation of the kernel. DECnet is the only user left so after
> converting it we can safely remove it
> 
> Thomas Graf (2):
>   decnet: Parse netlink attributes on our own
>   rtnetlink: Remove passing of attributes into rtnl_doit functions

Looks great.

I'll apply this once at least some basic sanity test has been done
on the decnet bits.

Thanks.
