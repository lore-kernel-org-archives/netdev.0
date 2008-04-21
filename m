From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 0/4] net: enable timestamps on a per-socket basis
Date: Mon, 21 Apr 2008 04:51:22 -0700 (PDT)
Message-ID: <20080421.045122.239401136.davem@davemloft.net>
References: <87y7777ahj.fsf@basil.nowhere.org>
	<20080421.035939.37324583.davem@davemloft.net>
	<480C7DE3.5020301@firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: juhlenko@akamai.com, netdev@vger.kernel.org,
	shemminger@linux-foundation.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40784
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754846AbYDULvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 07:51:21 -0400
In-Reply-To: <480C7DE3.5020301@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Mon, 21 Apr 2008 13:43:31 +0200

> Are you sure they don't just need end2end timestamps as in from sendmsg
> to recvmsg()? Imagine the packet is stuck for some time in the
> kernel for whatever reason and you only process it later in user space
> wouldn't you consider that older time stamp "inaccurate" too? I would,
> unless I was debugging the network stack.

They need the exact timestamp when the packet was received at the
physical machine (and this pretty much means the network card) so that
they know precisely when customer X's trade order arrived for
scheduling and prioritizing purposes.

> It is hard to imagine they really care about excluding one set of queues
> (kernel queue) and not other queues (nic rx/tx queues, switch queues
> etc.) for their time stamps as you imply.

They do.
