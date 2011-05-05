From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 1/2] net: Export dev_queue_xmit_nit for use by
 macvlan driver
Date: Thu, 05 May 2011 10:50:19 -0700 (PDT)
Message-ID: <20110505.105019.112577258.davem@davemloft.net>
References: <1304036552-1589-1-git-send-email-david.ward@ll.mit.edu>
	<1304036552-1589-2-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: david.ward@ll.mit.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42025
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751061Ab1EERuw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2011 13:50:52 -0400
In-Reply-To: <1304036552-1589-2-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ward <david.ward@ll.mit.edu>
Date: Thu, 28 Apr 2011 20:22:31 -0400

> @@ -1521,11 +1521,13 @@ static inline int deliver_skb(struct sk_buff *skb,
>  }
>  
>  /*
> - *	Support routine. Sends outgoing frames to any network
> - *	taps currently in use.
> + * dev_queue_xmit_nit - send outgoing frame to AF_PACKET sockets
> + *
> + * @skb: buffer to send
> + * @dev: network device that AF_PACKET sockets are attached to (if any)
>   */

Your change to this comment is inaccurate.

AF_PACKET is only one of several types of entities that register these
kinds of taps.

Also, I really don't like exposing these kinds of internals for what is
largely a macvlan internal issue.  Please find a less intrustive way
to solve this problem.

Thanks.
