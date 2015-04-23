From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev_alloc_pcpu_stats: use less common iterator
 variable
Date: Thu, 23 Apr 2015 11:41:43 -0400 (EDT)
Message-ID: <20150423.114143.628350974842866662.davem@davemloft.net>
References: <1429783590-31158-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johannes.berg@intel.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42024 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965185AbbDWPlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 11:41:45 -0400
In-Reply-To: <1429783590-31158-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Thu, 23 Apr 2015 12:06:30 +0200

> From: Johannes Berg <johannes.berg@intel.com>
> 
> With the CPU iteration variable called 'i', it's relatively easy
> to have variable shadowing which sparse will warn about. Avoid
> that by renaming the variable to __cpu which is less likely to
> be used in the surrounding context.
> 
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

Applied, thanks.
