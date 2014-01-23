From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: Correctly sync addresses from multiple sources
 to single device
Date: Thu, 23 Jan 2014 13:07:20 -0800 (PST)
Message-ID: <20140123.130720.1596532534979092173.davem@davemloft.net>
References: <52DFD32D.4060805@oktetlabs.ru>
	<1390413255-32223-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrey.dmitrov@oktetlabs.ru,
	Alexandra.Kossovsky@oktetlabs.ru, Konstantin.Ushakov@oktetlabs.ru
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60203 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750881AbaAWVHV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 16:07:21 -0500
In-Reply-To: <1390413255-32223-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Wed, 22 Jan 2014 12:54:15 -0500

> When we have multiple devices attempting to sync the same address
> to a single destination, each device should be permitted to sync
> it once.  To accomplish this, pass the 'sync_cnt' of the source
> address when adding the addresss to the lower device.  'sync_cnt'
> tracks how many time a given address has been succefully synced.
> This way, we know that if the 'sync_cnt' passed in is 0, we should
> sync this address.
> 
> Also, turn 'synced' member back into the counter as was originally
> done in
>    commit 4543fbefe6e06a9e40d9f2b28d688393a299f079.
>    net: count hw_addr syncs so that unsync works properly.
> It tracks how many time a given address has been added via a
> 'sync' operation.  For every successfull 'sync' the counter is
> incremented, and for ever 'unsync', the counter is decremented.
> This makes sure that the address will be properly removed from
> the the lower device when all the upper devices have removed it.
> 
> Reported-by: Andrey Dmitrov <andrey.dmitrov@oktetlabs.ru>
> CC: Andrey Dmitrov <andrey.dmitrov@oktetlabs.ru>
> CC: Alexandra N. Kossovsky <Alexandra.Kossovsky@oktetlabs.ru>
> CC: Konstantin Ushakov <Konstantin.Ushakov@oktetlabs.ru>
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

This one compiles, great :-)

Applied, thanks Vlad.
