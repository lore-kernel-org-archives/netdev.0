From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix nexthop lookups
Date: Thu, 20 Aug 2015 14:43:18 -0700 (PDT)
Message-ID: <20150820.144318.244803021544136970.davem@davemloft.net>
References: <1029376325.2912846.1439917035503.JavaMail.zimbra@tpip.net>
	<1440009631-8082-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57370 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752053AbbHTVnT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 17:43:19 -0400
In-Reply-To: <1440009631-8082-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed, 19 Aug 2015 11:40:31 -0700

> Andreas reported breakage adding routes with local nexthops:
> $ ip route show table main
> ...
> 172.28.0.0/24 dev vnf-xe1p0  proto kernel  scope link  src 172.28.0.16
> 
> $ ip route add 10.0.0.0/8 via 172.28.0.32 table 100 dev vnf-xe1p0
> RTNETLINK answers: Resource temporarily unavailable
> 
> 3bfd847203c changed the lookup to use the passed in table but for cases like
> this the nexthop is in the local table rather than the passed in table.
> 
> Fixes: 3bfd847203c ("net: Use passed in table for nexthop lookups")
> Reported-by: Andreas Schultz <aschultz@tpip.net>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied to net-next, thanks David.

Please be explicit in the future about what tree your patch is targetted
at by either saying "[PATCH net]" or "[PATCH net-next]" in your subject.

Thanks.
