From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] ipv6: clean up anycast when an interface is
 destroyed
Date: Fri, 12 Sep 2014 17:33:28 -0400 (EDT)
Message-ID: <20140912.173328.853747388797023828.davem@davemloft.net>
References: <CAHA+R7ODewXP69ULsR0RD+c3BEfMa90zATRjHF3dC9Dkv7jgZw@mail.gmail.com>
	<20140910.135840.133555874665251669.davem@davemloft.net>
	<20140910212302.GA26184@kria>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cwang@twopensource.com, netdev@vger.kernel.org,
	hannes@stressinduktion.org
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51442 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752770AbaILVdb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 17:33:31 -0400
In-Reply-To: <20140910212302.GA26184@kria>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Wed, 10 Sep 2014 23:23:02 +0200

> If we try to rmmod the driver for an interface while sockets with
> setsockopt(JOIN_ANYCAST) are alive, some refcounts aren't cleaned up
> and we get stuck on:
> 
>   unregister_netdevice: waiting for ens3 to become free. Usage count = 1
> 
> If we LEAVE_ANYCAST/close everything before rmmod'ing, there is no
> problem.
> 
> We need to perform a cleanup similar to the one for multicast in
> addrconf_ifdown(how == 1).
> 
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> ---
> v2: remove comment

Applied, thank you.
