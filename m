From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next-2.6 0/3] net: remove ndo_set_multicast_list
Date: Wed, 17 Aug 2011 20:22:22 -0700 (PDT)
Message-ID: <20110817.202222.1587060016276975049.davem@davemloft.net>
References: <1313512142-3355-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, kaber@trash.net, yoshfuji@linux-ipv6.org,
	rdunlap@xenotime.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	mirqus@gmail.com, jesse@nicira.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59207 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752976Ab1HRDZP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2011 23:25:15 -0400
In-Reply-To: <1313512142-3355-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Tue, 16 Aug 2011 18:28:59 +0200

> Now we have 2 callbacks exported to drivers to set rx filtering:
> ndo_set_multicast_list
> ndo_set_rx_mode
> 
> The second one was added with second unicast address list and only drivers
> that are able to handle unicast filtering should use that. 
> 
> Having these two together is confusing and as I found out in many drivers,
> developers are not using them properly. So just kill one of them.
> ndo_set_multicast_list gets the bullet because I believe that name "set_rx_mode"
> is more appropriate.
> 
> IFF_UNICAST_FLT flag is used so core know if driver handles unicast filtering.
> 
> applies cleanly on most recent net-next with "[patch net-next-2.6 v2] bonding: use ndo_change_rx_flags callback"

All applied, thanks Jiri!
