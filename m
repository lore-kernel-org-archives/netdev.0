From: David Miller <davem@davemloft.net>
Subject: Re: [NETLINK]: Do precise netlink message allocations where
 possible
Date: Fri, 10 Nov 2006 14:10:33 -0800 (PST)
Message-ID: <20061110.141033.55510094.davem@davemloft.net>
References: <20061110121706.GH8693@postel.suug.ch>
	<4554A2FE.2020405@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:18110
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S966111AbWKJWKc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Nov 2006 17:10:32 -0500
To: paul.moore@hp.com
In-Reply-To: <4554A2FE.2020405@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <paul.moore@hp.com>
Date: Fri, 10 Nov 2006 11:04:14 -0500

> Thomas Graf wrote:
> > Account for the netlink message header size directly in nlmsg_new()
> > instead of relying on the caller calculate it correctly.
> > 
> > Replaces error handling of message construction functions when
> > constructing notifications with bug traps since a failure implies
> > a bug in calculating the size of the skb.
> > 
> > Signed-off-by: Thomas Graf <tgraf@suug.ch>
 ...
> I like this approach, it makes much more sense to me then the previous
> implementation which was a simple "alias" to alloc_skb().  Also, the NetLabel
> relevant sections look fine to me.
> 
> Acked-by: Paul Moore <paul.moore@hp.com>

I like it a lot too.

Applied, thanks Thomas.
