From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] genetlink: fix genlmsg_multicast() bug
Date: Thu, 21 Nov 2013 13:18:09 -0500 (EST)
Message-ID: <20131121.131809.935111586164423904.davem@davemloft.net>
References: <1385054224-1410-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johannes.berg@intel.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43500 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752640Ab3KUSSK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 13:18:10 -0500
In-Reply-To: <1385054224-1410-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Thu, 21 Nov 2013 18:17:04 +0100

> From: Johannes Berg <johannes.berg@intel.com>
> 
> Unfortunately, I introduced a tremendously stupid bug into
> genlmsg_multicast() when doing all those multicast group
> changes: it adjusts the group number, but then passes it
> to genlmsg_multicast_netns() which does that again.
> 
> Somehow, my tests failed to catch this, so add a warning
> into genlmsg_multicast_netns() and remove the offending
> group ID adjustment.
> 
> Also add a warning to the similar code in other functions
> so people who misuse them are more loudly warned.
> 
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

Applied.
