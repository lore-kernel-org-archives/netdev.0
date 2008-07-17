From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] core: add stat to track unresolved discards in
 neighbor cache
Date: Wed, 16 Jul 2008 20:50:59 -0700 (PDT)
Message-ID: <20080716.205059.206038375.davem@davemloft.net>
References: <20080715173731.GF4918@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60024
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753900AbYGQDu7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 23:50:59 -0400
In-Reply-To: <20080715173731.GF4918@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue, 15 Jul 2008 13:37:31 -0400

> in __neigh_event_send, if we have a neighbour entry which is in NUD_INCOMPLETE
> state, we enqueue any outbound frames to that neighbour to the neighbours
> arp_queue, which is default capped to a length of 3 skbs.  If that queue exceeds
> its set length, it will drop an skb on the queue to enqueue the newly arrived
> skb.  This results in a drop for which we have no statistics incremented.  This
> patch adds an unresolved_discards stat to /proc/net/stat/ndisc_cache to track
> these lost frames.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied, thanks a lot Neil.
