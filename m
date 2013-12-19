From: David Miller <davem@davemloft.net>
Subject: Re: HW accelerated support for setting skb->pkt_type?
Date: Thu, 19 Dec 2013 00:16:45 -0500 (EST)
Message-ID: <20131219.001645.1578105338168883753.davem@davemloft.net>
References: <CAGVrzca0P64D181XHjcXMOSMMsyyOEEGjH2KO9bChnN0dAbaTg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58949 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750954Ab3LSFQr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 00:16:47 -0500
In-Reply-To: <CAGVrzca0P64D181XHjcXMOSMMsyyOEEGjH2KO9bChnN0dAbaTg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 18 Dec 2013 18:29:37 -0800

> I work with two Ethernet controllers which can tell on a per-packet
> basis whether this is a broadcast, unicast or multicast, eventually
> allowing me to bypass the initial checks done in eth_type_trans().
> 
> Is there any other hardware out there which supports that, and is
> there any interest in optimizing that operation?

There is zero benefit from this, since you're going to have to touch
the packet headers anyways and the memory access from that dwarfs
anything else.
