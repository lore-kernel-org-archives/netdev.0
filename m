From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netlink: add NETLINK_BROADCAST_ERROR socket option
Date: Wed, 18 Feb 2009 12:43:36 +0100
Message-ID: <499BF468.5010406@trash.net>
References: <20090218114042.7060.54127.stgit@Decadence>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50205 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851AbZBRLnk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 06:43:40 -0500
In-Reply-To: <20090218114042.7060.54127.stgit@Decadence>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pablo Neira Ayuso wrote:
> This patch adds NETLINK_BROADCAST_ERROR which is a netlink
> socket option that the listener can set to make netlink_broadcast()
> return errors in the delivery to the caller. This option is useful
> if the caller of netlink_broadcast() do something with the result
> of the message delivery, like in ctnetlink where it drops a network
> packet if the event delivery failed, this is used to enable reliable
> logging and state-synchronization. If this socket option is not set,
> netlink_broadcast() only reports ESRCH errors and silently ignore
> ENOBUFS errors, which is what most netlink_broadcast() callers
> should do.
> 
> This socket option is based on a suggestion from Patrick McHardy.
> Patrick McHardy can exchange this patch for a beer from me ;).

I'd accept that offer, but it needs to go through Dave :)
Anyways, the patch looks good.

Acked-by: Patrick McHardy <kaber@trash.net>
