From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] netlink/genetlink cleanups & multicast improvements
Date: Thu, 25 Dec 2014 18:26:43 -0500 (EST)
Message-ID: <20141225.182643.2281873118805231449.davem@davemloft.net>
References: <1419270999-22165-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58624 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751431AbaLYX07 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Dec 2014 18:26:59 -0500
In-Reply-To: <1419270999-22165-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Mon, 22 Dec 2014 18:56:34 +0100

> I'm looking at using the multicast group functionality in a way that would
> benefit from knowing when there are subscribers to avoid collecting the
> required data when there aren't any. During this I noticed that the unbind
> for multicast groups doesn't actually work - it's never called when sockets
> are closed. Luckily, nobody actually uses the functionality.
> 
> While looking at the code trying to find why it's not called and where the
> multicast listeners are actually removed, I found the potential cleanup in
> patch 3. Patch 2 also has a cleanup for a generic netlink API in this area.

Series applied, using v2 of patch #5.
