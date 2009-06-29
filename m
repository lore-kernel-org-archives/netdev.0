From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] be2net: Fix to avoid a crash seen on PPC with
 LRO and Jumbo frames.
Date: Sun, 28 Jun 2009 17:35:00 -0700 (PDT)
Message-ID: <20090628.173500.193717467.davem@davemloft.net>
References: <20090626125054.GA25517@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51523
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751269AbZF2Aez (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jun 2009 20:34:55 -0400
In-Reply-To: <20090626125054.GA25517@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitk@serverengines.com>
Date: Fri, 26 Jun 2009 18:21:07 +0530

> While testing the driver on PPC, we ran into a crash with LRO, Jumbo frames.
> With CONFIG_PPC_64K_PAGES configured (a default in PPC), MAX_SKB_FRAGS drops to 3 and we were crossing the array limits on skb_shinfo(skb)->frags[]. 
> Now we coalesce the frags from the same physical page into one slot in 
> skb_shinfo(skb)->frags[] and go to the next index when the frag is from 
> different physical page.
> 
> This patch is against the net-2.6 tree.
> 
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

This patch looks good, applied, thanks!
