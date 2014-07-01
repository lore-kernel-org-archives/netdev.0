From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 2/2] ipv6: Allow accepting RA from local IP
 addresses.
Date: Tue, 01 Jul 2014 12:16:42 -0700 (PDT)
Message-ID: <20140701.121642.1053713287864156303.davem@davemloft.net>
References: <1403732693-18282-1-git-send-email-greearb@candelatech.com>
	<1403732693-18282-2-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34710 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932344AbaGATQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2014 15:16:43 -0400
In-Reply-To: <1403732693-18282-2-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: greearb@candelatech.com
Date: Wed, 25 Jun 2014 14:44:53 -0700

> From: Ben Greear <greearb@candelatech.com>
> 
> This can be used in virtual networking applications, and
> may have other uses as well.  The option is disabled by
> default.
> 
> A specific use case is setting up virtual routers, bridges, and
> hosts on a single OS without the use of network namespaces or
> virtual machines.  With proper use of ip rules, routing tables,
> veth interface pairs and/or other virtual interfaces,
> and applications that can bind to interfaces and/or IP addresses,
> it is possibly to create one or more virtual routers with multiple
> hosts attached.  The host interfaces can act as IPv6 systems,
> with radvd running on the ports in the virtual routers.  With the
> option provided in this patch enabled, those hosts can now properly
> obtain IPv6 addresses from the radvd.
> 
> Signed-off-by: Ben Greear <greearb@candelatech.com>
> ---
> 
> v3:  Update commit message to describe use case, remove helper method,
>    tweak kernel message upon failure to accept RA.

Applied.
