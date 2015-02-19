From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Reflect RX hash for transmit
Date: Thu, 19 Feb 2015 15:54:49 -0500 (EST)
Message-ID: <20150219.155449.1055446417050184538.davem@davemloft.net>
References: <1424025438-1659-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57687 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752886AbbBSUyv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 15:54:51 -0500
In-Reply-To: <1424025438-1659-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Sun, 15 Feb 2015 10:37:18 -0800

> This patch allows a driver to request that the receive hash it provides
> to the stack is reflected back in skb->hash for packets transmitted
> on the associated connection. The hash value returned by a device could
> have meaning when used in transmit to identify a flow, for instance
> the hash may by a flow ID for a flow created in a (virtual) device.
> With the flow ID provided on transmit this can obviate the need
> to create the hash and do the lookup on the fly in transmit.
> 
> Note that this is an opportunistic optimization, there is no
> separate negotiation between the stack and driver/device for
> the hash used in either TX or RX.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Like Eric, I'd like to see this resubmitted alongside an actual user
of the new facility.

Thanks!
