From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macvlan: Propagate promiscuity setting to lower
 devices.
Date: Mon, 04 May 2015 00:14:56 -0400 (EDT)
Message-ID: <20150504.001456.193382168898312074.davem@davemloft.net>
References: <1430516197-3271-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevic@redhat.com
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59593 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750832AbbEDEO5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 00:14:57 -0400
In-Reply-To: <1430516197-3271-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Yasevich <vyasevich@gmail.com>
Date: Fri,  1 May 2015 17:36:37 -0400

> When a macvlan device is placed in promiscuous mode, it currently
> just sets it's multicast mask to permissive, but doesn't change
> the state of the lower device.  As a result, not all multicast
> traffic can be received on such device.  Additionally, none of
> a vlan traffic can be received on such device as well.
> This patch propagates the promiscuous mode setting to lower device
> so that lower device may receive all packets that macvlan may
> be interested in.
> 
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>

Applied, thanks Vlad.
