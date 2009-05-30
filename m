From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: introduce pre-up netdev notifier
Date: Fri, 29 May 2009 22:09:06 -0700 (PDT)
Message-ID: <20090529.220906.243061042.davem@davemloft.net>
References: <1243640394.13863.7.camel@johannes.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52321
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753230AbZE3FJG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 May 2009 01:09:06 -0400
In-Reply-To: <1243640394.13863.7.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Sat, 30 May 2009 01:39:53 +0200

> NETDEV_UP is called after the device is set UP, but sometimes
> it is useful to be able to veto the device UP. Introduce a
> new NETDEV_PRE_UP notifier that can be used for exactly this.
> The first use case will be cfg80211 denying interfaces to be
> set UP if the device is known to be rfkill'ed.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
> ---
> John, please take this patch via your tree, I asked Dave and
> he's cool with that.

Yep:

Acked-by: David S. Miller <davem@davemloft.net>
