From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] mac80211: free netdev on dev_alloc_name() error
Date: Fri, 09 Jun 2017 15:40:36 -0400 (EDT)
Message-ID: <20170609.154036.1650264279344295227.davem@davemloft.net>
References: <20170609193309.14972-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        johannes.berg@intel.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38064 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751584AbdFITkh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 15:40:37 -0400
In-Reply-To: <20170609193309.14972-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Fri,  9 Jun 2017 21:33:09 +0200

> From: Johannes Berg <johannes.berg@intel.com>
> 
> The change to remove free_netdev() from ieee80211_if_free()
> erroneously didn't add the necessary free_netdev() for when
> ieee80211_if_free() is called directly in one place, rather
> than as the priv_destructor. Add the missing call.
> 
> Fixes: cf124db566e6 ("net: Fix inconsistent teardown and release of private netdev state.")
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

Applied, thanks Johannes.
