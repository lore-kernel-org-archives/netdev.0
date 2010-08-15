From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] netlink: netlink_recvmsg() fix
Date: Sat, 14 Aug 2010 22:37:22 -0700 (PDT)
Message-ID: <20100814.223722.116371746.davem@davemloft.net>
References: <1281710115.3760.27.camel@jlt3.sipsolutions.net>
	<1281710887.4470.78.camel@edumazet-laptop>
	<1281712433.2116.15.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59153
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754682Ab0HOFhE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Aug 2010 01:37:04 -0400
In-Reply-To: <1281712433.2116.15.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Fri, 13 Aug 2010 17:13:53 +0200

> On Fri, 2010-08-13 at 16:48 +0200, Eric Dumazet wrote:
> 
>> I assume reverting 1235f504aaba removes these errors ?
> 
> I haven't tried yet, but it only happened very recently and I didn't
> find any other candidate -- the error always points to
> wireless_send_event too.

Please test with the commit reverted and let us know if it helps.

The current situation is worse than what we were trying to fix
in that commit, so if a revert fixes your problem then as Eric
said we should do that first.
