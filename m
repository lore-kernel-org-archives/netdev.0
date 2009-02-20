From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: add NETLINK_BROADCAST_ERROR socket option
Date: Fri, 20 Feb 2009 01:01:29 -0800 (PST)
Message-ID: <20090220.010129.217009353.davem@davemloft.net>
References: <20090218114042.7060.54127.stgit@Decadence>
	<499BF468.5010406@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40576
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752036AbZBTJBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2009 04:01:47 -0500
In-Reply-To: <499BF468.5010406@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 18 Feb 2009 12:43:36 +0100

> Pablo Neira Ayuso wrote:
> > This patch adds NETLINK_BROADCAST_ERROR which is a netlink
> > socket option that the listener can set to make netlink_broadcast()
> > return errors in the delivery to the caller. This option is useful
> > if the caller of netlink_broadcast() do something with the result
> > of the message delivery, like in ctnetlink where it drops a network
> > packet if the event delivery failed, this is used to enable reliable
> > logging and state-synchronization. If this socket option is not set,
> > netlink_broadcast() only reports ESRCH errors and silently ignore
> > ENOBUFS errors, which is what most netlink_broadcast() callers
> > should do.
> > This socket option is based on a suggestion from Patrick McHardy.
> > Patrick McHardy can exchange this patch for a beer from me ;).
> 
> I'd accept that offer, but it needs to go through Dave :)
> Anyways, the patch looks good.
> 
> Acked-by: Patrick McHardy <kaber@trash.net>

Applied, thanks guys.
