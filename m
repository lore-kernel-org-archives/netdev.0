From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skbuff: make skb_put_zero() return void
Date: Thu, 15 Jun 2017 12:18:06 -0400 (EDT)
Message-ID: <20170615.121806.1737755943471705142.davem@davemloft.net>
References: <20170614201720.21070-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johannes.berg@intel.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55976 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750816AbdFOQSI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 12:18:08 -0400
In-Reply-To: <20170614201720.21070-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Wed, 14 Jun 2017 22:17:20 +0200

> From: Johannes Berg <johannes.berg@intel.com>
> 
> It's nicer to return void, since then there's no need to
> cast to any structures. Currently none of the users have
> a cast, but a number of future conversions do.
> 
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

Applied.

Although a bit disruptive, it might be nice to convert all of the
other "char *" related data pointers in skbuff based interfaces.

No, I'm not asking you specifically to work on this, relax :)
