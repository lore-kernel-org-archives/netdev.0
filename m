From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-next 2011-08-02
Date: Tue, 02 Aug 2011 14:39:55 -0700 (PDT)
Message-ID: <20110802.143955.1785360722763378138.davem@davemloft.net>
References: <20110802181131.GH14167@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60111 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755367Ab1HBVlA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Aug 2011 17:41:00 -0400
In-Reply-To: <20110802181131.GH14167@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Tue, 2 Aug 2011 14:11:31 -0400

> Here are a few more fixes intended for 3.1.  Dan Carpenter gives us an
> off-by-one fix in the scan trigger code for nl80211.  Felix gives us a
> fix for tx power initialization for ath9k.  Larry fixes an oops on ARM
> by rewriting some init code to avoid checking something that doesn't get
> initialized on ARM.  This round's big hero is Stanislaw, who gives us a
> brown paper bag fix for some skb handling in rt2x00, an ath9k fix to
> avoid hangs on systems w/ ASPM disabled, and an iwlegacy fix to ensure
> that tx power settings are applied properly.
> 
> Please let me know if there are problems!

I'll pull this, but I think once you've sent me all of your features
for the merge window you should drop "-next" from the name of the
tree and/or branches you ask me to pull from.

This makes it entirely clear that you're sending me bug fixes and not
features and cleanups.

Thanks.
