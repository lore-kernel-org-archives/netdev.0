From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/9] genetlink: clean up multicast group APIs
Date: Tue, 19 Nov 2013 16:40:34 -0500 (EST)
Message-ID: <20131119.164034.545622999253259387.davem@davemloft.net>
References: <1384870779-17571-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58346 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752337Ab3KSVkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Nov 2013 16:40:37 -0500
In-Reply-To: <1384870779-17571-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Tue, 19 Nov 2013 15:19:30 +0100

> The generic netlink multicast group registration doesn't have to
> be dynamic, and can thus be simplified just like I did with the
> ops. This removes some complexity in registration code.
> 
> Additionally, two users of generic netlink already use multicast
> groups in a wrong way, add workarounds for those two to keep the
> userspace API working, but at the same time make them not clash
> with other users of multicast groups as might happen now.
> 
> While making it all a bit easier, also prevent such abuse by adding
> checks to the APIs so each family can only use the groups it owns.

This looks great, and makes the unfortunate multicast ID handling in
DM and elsewhere explicit, controlled, and validated.

Series applied, thanks.
