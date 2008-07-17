From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] core: add stat to track unresolved discards in neighbor cache
Date: Thu, 17 Jul 2008 06:58:22 -0400
Message-ID: <20080717105821.GA17892@hmsendeavour.rdu.redhat.com>
References: <20080715173731.GF4918@hmsreliant.think-freely.org> <20080716.205059.206038375.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2469 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751130AbYGQK7M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2008 06:59:12 -0400
Content-Disposition: inline
In-Reply-To: <20080716.205059.206038375.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 16, 2008 at 08:50:59PM -0700, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Tue, 15 Jul 2008 13:37:31 -0400
> 
> > in __neigh_event_send, if we have a neighbour entry which is in NUD_INCOMPLETE
> > state, we enqueue any outbound frames to that neighbour to the neighbours
> > arp_queue, which is default capped to a length of 3 skbs.  If that queue exceeds
> > its set length, it will drop an skb on the queue to enqueue the newly arrived
> > skb.  This results in a drop for which we have no statistics incremented.  This
> > patch adds an unresolved_discards stat to /proc/net/stat/ndisc_cache to track
> > these lost frames.
> > 
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> 
> Applied, thanks a lot Neil.
Thank you Dave.
Neil

-- 
/***************************************************
 *Neil Horman
 *nhorman@tuxdriver.com
 *gpg keyid: 1024D / 0x92A74FA1
 *http://pgp.mit.edu
 ***************************************************/
