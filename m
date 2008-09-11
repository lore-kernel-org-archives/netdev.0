From: David Miller <davem@davemloft.net>
Subject: Re: ipv6 neighbour code keeps interfaces held
Date: Thu, 11 Sep 2008 14:46:19 -0700 (PDT)
Message-ID: <20080911.144619.17474001.davem@davemloft.net>
References: <1221081539.3804.33.camel@johannes.berg>
	<20080910.164009.92497081.davem@davemloft.net>
	<1221149559.6986.30.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35156
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753081AbYIKVq0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 17:46:26 -0400
In-Reply-To: <1221149559.6986.30.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Thu, 11 Sep 2008 18:12:38 +0200

> On Wed, 2008-09-10 at 16:40 -0700, David Miller wrote:
> 
> > Here is a quick patch that might resolve this specific situation.
> > Let me know how it works for you:
> 
> I haven't seen it again so far, but it's not necessarily an indication
> that it worked. But normally I think I probably would have seen it
> already by now.

Thanks for the feedback.

I put this fix into net-next-2.6, and what I'll likely do is backport
this to net-2.6 and -stable if you still don't see if after a few more
days.

