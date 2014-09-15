From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: Fix br_should_learn to check vlan_enabled
Date: Mon, 15 Sep 2014 17:38:49 -0400 (EDT)
Message-ID: <20140915.173849.609066505150727105.davem@davemloft.net>
References: <1410809066-4434-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, toshiaki.makita1@gmail.com,
	vyasevic@redhat.com
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40120 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754585AbaIOViw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 17:38:52 -0400
In-Reply-To: <1410809066-4434-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Yasevich <vyasevich@gmail.com>
Date: Mon, 15 Sep 2014 15:24:26 -0400

> As Toshiaki Makita pointed out, the BRIDGE_INPUT_SKB_CB will
> not be initialized in br_should_learn() as that function
> is called only from br_handle_local_finish().  That is
> an input handler for link-local ethernet traffic so it perfectly
> correct to check br->vlan_enabled here.
> 
> Reported-by: Toshiaki Makita<toshiaki.makita1@gmail.com>
> Fixes: 20adfa1 bridge: Check if vlan filtering is enabled only once.
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>

Applied, thanks Vlad.
