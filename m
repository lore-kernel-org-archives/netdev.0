From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: Send ALB learning packets using the right
 source
Date: Thu, 22 May 2014 15:48:17 -0400 (EDT)
Message-ID: <20140522.154817.2015811612495572736.davem@davemloft.net>
References: <1400692788-26995-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
	andy@greyhouse.net
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42061 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750890AbaEVTsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 15:48:19 -0400
In-Reply-To: <1400692788-26995-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Wed, 21 May 2014 13:19:48 -0400

> ALB learning packets are currentlyalways sent using the slave mac
> address for all vlans configured on top of bond.   This is not always
> correct, as vlans may change their mac address.
> This patch introduced a concept of strict matching where the
> source of learning packets can either strictly match the address
> passed in, or it can determine a more correct address to use.
> 
> There are 3 casese to consider:
>   1) Switchover.  In this case, we have a new active slave and we need
>      tell the switch about all addresses available on the slave.
>   2) Monitor.  We'll periodically refresh learning info for all slaves.
>      In this case, we refresh all addresses for current active, and just
>      the slave address for other slaves.
>   3) Teaching of disabled adddress.  This happens as part of the
>      failover and in this case, we alwyas to use just the address
>      provided.
> 
> CC: Jay Vosburgh <j.vosburgh@gmail.com>
> CC: Veaceslav Falico <vfalico@gmail.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

Applied, thanks Vlad.
