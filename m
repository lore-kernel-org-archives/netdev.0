From: David Miller <davem@davemloft.net>
Subject: Re: netlink stats: Ability to get stats for a single device?
Date: Tue, 26 Oct 2010 12:38:11 -0700 (PDT)
Message-ID: <20101026.123811.13746869.davem@davemloft.net>
References: <4CC72C80.9010802@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33369
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753150Ab0JZThs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 15:37:48 -0400
In-Reply-To: <4CC72C80.9010802@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Tue, 26 Oct 2010 12:31:12 -0700

> Am I missing something, or do I just need to write up a patch
> to have netlink pay attention to the ifindex?

Setting the ->ifi_index or IFLA_IFNAME attribute values appropriately
in the getlink request doesn't work?

That should give you back, amonst other things, the rtnl_link_stats
for the device in the netlink response.
