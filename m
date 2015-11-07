From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] packet: do skb_probe_transport_header when we
 actually have data
Date: Sat, 07 Nov 2015 17:29:28 -0500 (EST)
Message-ID: <20151107.172928.239564395518699740.davem@davemloft.net>
References: <1446900176.17135.4.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151107.133502.833614670001999282.davem@davemloft.net>
	<1446922430.17135.13.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, edumazet@google.com, willemb@google.com,
	tklauser@distanz.ch, netdev@vger.kernel.org, jasowang@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60796 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752400AbbKGW3c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Nov 2015 17:29:32 -0500
In-Reply-To: <1446922430.17135.13.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 07 Nov 2015 10:53:50 -0800

> Well, imagine following scenario (a real one, as I use it all of
> time, thus how I discovered all trafgen traffic ends up on one slave
> only)
> 
> Even if qdisc is bypassed on the bond0, the current handling does
> not prevent going to the slave qdiscs.

Ok, depending upon the semantics Daniel intended, we may have to add
a qdisc bypass boolean bit to SKBs.
