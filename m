From: David Miller <davem@davemloft.net>
Subject: Re: TCP packet size and delivery packet decisions
Date: Tue, 07 Sep 2010 09:35:48 -0700 (PDT)
Message-ID: <20100907.093548.183061848.davem@davemloft.net>
References: <AANLkTik75BGz=csDKVRk+Ni9__MqXMpHeqi_sHniu09A@mail.gmail.com>
	<20100906.223010.173858342.davem@davemloft.net>
	<1283859552.2338.402.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leandroal@gmail.com, netdev@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58561
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756678Ab0IGQfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 12:35:31 -0400
In-Reply-To: <1283859552.2338.402.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 07 Sep 2010 13:39:12 +0200

> I am not sure why TSO added a "Bound mss with half of window"
> requirement for tcp_sync_mss()

Because if we TSO to the full window the link doesn't fill up
properly.

We definitely do this on purpose, that's for sure.  :-)

I'll look into the full version control history to unearth the
exact reason so we can validate your patch, good find Eric.
