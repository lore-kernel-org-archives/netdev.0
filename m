From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cfg80211: make RATE_INFO_BW_20 the default
Date: Thu, 04 May 2017 13:15:56 -0400 (EDT)
Message-ID: <20170504.131556.1661934833868050918.davem@davemloft.net>
References: <20170504064230.22058-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, torvalds@linux-foundation.org,
        netdev@vger.kernel.org, johannes.berg@intel.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58254 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932279AbdEDRP7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 13:15:59 -0400
In-Reply-To: <20170504064230.22058-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Thu,  4 May 2017 08:42:30 +0200

> From: Johannes Berg <johannes.berg@intel.com>
> 
> Due to the way I did the RX bitrate conversions in mac80211 with
> spatch, going setting flags to setting the value, many drivers now
> don't set the bandwidth value for 20 MHz, since with the flags it
> wasn't necessary to (there was no 20 MHz flag, only the others.)
> 
> Rather than go through and try to fix up all the drivers, instead
> renumber the enum so that 20 MHz, which is the typical bandwidth,
> actually has the value 0, making those drivers all work again.
> 
> If VHT was hit used with a driver not reporting it, e.g. iwlmvm,
> this manifested in hitting the bandwidth warning in
> cfg80211_calculate_bitrate_vht().
> 
> Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

Since Jens Axboe had the same problem and tested this patch, I'm
tossing it into my tree.

Just FYI...
