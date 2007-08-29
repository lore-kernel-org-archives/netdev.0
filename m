From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] make _minimum_ TCP retransmission timeout configurable
Date: Wed, 29 Aug 2007 16:15:28 -0700 (PDT)
Message-ID: <20070829.161528.38309258.davem@davemloft.net>
References: <46D5F32F.2070502@hp.com>
	<20070829.153503.18295527.davem@davemloft.net>
	<46D5FBF3.5050700@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ian.mcdonald@jandi.co.nz, netdev@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33827
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751407AbXH2XP3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 19:15:29 -0400
In-Reply-To: <46D5FBF3.5050700@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Wed, 29 Aug 2007 16:06:27 -0700

> I belive the biggest component comes from link-layer retransmissions. 
> There can also be some short outtages thanks to signal blocking, 
> tunnels, people with big hats and whatnot that the link-layer 
> retransmissions are trying to address.  The three seconds seems to be a 
> value that gives the certainty that 99 times out of 10 the segment was 
> indeed lost.
> 
> The trace I've been sent shows clean RTTs ranging from ~200 milliseconds 
> to ~7000 milliseconds.

Thanks for the info.

It's pretty easy to generate examples where we might have some sockets
talking over interfaces on such a network and others which are not.
Therefore, if we do this, a per-route metric is probably the best bet.

Ilpo, I'm also very interested to see what you think of all of this
:-)
