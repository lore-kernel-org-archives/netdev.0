From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] ipv6: Enable netlink notification for tentative
 addresses.
Date: Thu, 26 Aug 2010 14:27:55 -0700 (PDT)
Message-ID: <20100826.142755.15249596.davem@davemloft.net>
References: <4C76C73F.4080206@hp.com>
	<20100826.131801.246519955.davem@davemloft.net>
	<4C76DA62.8040109@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41891
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754061Ab0HZV1k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 17:27:40 -0400
In-Reply-To: <4C76DA62.8040109@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Thu, 26 Aug 2010 14:19:30 -0700

> In our case, we enable IPv6 in user-space, and then we want to get
> some immediate indication that indeed the process is working as
> expected.

When DAD completes, you'll get a similar indication.

> In other cases, we want to remove all IPv6 addresses, so if we have
> not even been notified that the IP exists, then we cannot know how
> to delete it.

You can add a netlink message to accomplish that.  This has been
asked for in other contexts as well.

> We've been running this patch for several years, and it has not
> caused any obvious problems with other tools, so I think it's safe
> enough.

And your level of exposure compared to upstream is...? :-)

Anyways, even if it's implemented in an error free way it's still
not necessary the best way to go about this.
