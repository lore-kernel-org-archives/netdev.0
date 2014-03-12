From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: reflect the fwmark for replies with no socket
Date: Wed, 12 Mar 2014 16:17:37 -0400 (EDT)
Message-ID: <20140312.161737.1125059989320204564.davem@davemloft.net>
References: <1394536541-25702-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41298 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752423AbaCLURj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 16:17:39 -0400
In-Reply-To: <1394536541-25702-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Tue, 11 Mar 2014 20:15:41 +0900

> Kernel-originated IP packets that have no user socket associated
> with them (e.g., ICMP errors and echo replies, TCP RSTs, etc.)
> are emitted with a mark of zero. Instead, make them have the
> same mark as the packet they are replying to.
> 
> This is consistent with TOS, which is also reflected from the
> incoming packet, and it allows the administrator to use
> mark-based routing, firewalling, etc. for these replies by
> marking the original packets inbound.
> 
> Also fix the IPv6 code to reflect the tclass in replies like the
> IPv4 code does.
> 
> Change-Id: Ifd8dd75016e60dc982e7860f720d45c27dcaf04c
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>

I don't think it's safe to change this behavior after all of this
time.

And incoming marks absolutely do not have any automatic relation
to what an administartor might want to use for output packets.

I'm not applying this, sorry.
