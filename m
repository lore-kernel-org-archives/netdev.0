From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 4/7] net: packet: use skb->dev as storage
 for skb orig len instead of skb->cb[]
Date: Sat, 28 Feb 2015 16:00:47 -0500 (EST)
Message-ID: <20150228.160047.214686672558902639.davem@davemloft.net>
References: <CAHsH6Guq33N755dcuNEmzgP06O=PBdy2Tzt5vSr-iRFoj4uGtw@mail.gmail.com>
	<20150228.150830.1726900309943339124.davem@davemloft.net>
	<CAHsH6GvvQxHbt4JJrotn3y=BG172Wbw4NrMD+gTUA_R=jbPDTw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: willemb@google.com, edumazet@google.com, shmulik.ladkani@gmail.com,
	linux-bluetooth@vger.kernel.org, marcel@holtmann.org,
	netdev@vger.kernel.org
To: eyal.birger@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34566 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220AbbB1VAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2015 16:00:54 -0500
In-Reply-To: <CAHsH6GvvQxHbt4JJrotn3y=BG172Wbw4NrMD+gTUA_R=jbPDTw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eyal Birger <eyal.birger@gmail.com>
Date: Sat, 28 Feb 2015 22:38:04 +0200

> My concern is that any value I pick based on the existing implementations
> would need to be adjusted come a protocol with a larger address length.

Then we need a method that requires protocols to register their
address length in a manner that will allow us to validate that
limit at compile time.

This is not rocket science.

Right now we're proposing to do utterly stupid shit like encoding
integers in device pointers in the sk_buff, when that is absolutely
not necessary at all.
