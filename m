From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH RFC] xfrm: Don't queue retransmitted packets if the
 original is still on the host
Date: Mon, 21 Oct 2013 16:51:10 +0200
Message-ID: <20131021145110.GB1509@secunet.com>
References: <20131016114246.GB7660@secunet.com>
 <20131018.161908.1422032342884472542.davem@davemloft.net>
 <1382127825.3284.37.camel@edumazet-glaptop.roam.corp.google.com>
 <20131018.163412.487683352492277510.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:38882 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752954Ab3JUOvM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Oct 2013 10:51:12 -0400
Content-Disposition: inline
In-Reply-To: <20131018.163412.487683352492277510.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 18, 2013 at 04:34:12PM -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 18 Oct 2013 13:23:45 -0700
> 
> > On Fri, 2013-10-18 at 16:19 -0400, David Miller wrote:
> >> From: Steffen Klassert <steffen.klassert@secunet.com>
> >> Date: Wed, 16 Oct 2013 13:42:47 +0200
> >> 
> >> > It does not make sense to queue retransmitted packets if the
> >> > original packet is still in some queue of this host. So add
> >> > a check to xdst_queue_output() and drop the packet if the
> >> > original packet is not yet sent.
> >> > 
> >> > Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> >> 
> >> I have no problems with this, what about you Eric?
> > 
> > It looks fine to me.
> > 
> > Acked-by: Eric Dumazet <edumazet@google.com>
> 
> Great, Steffen I assume you'll merge this in via your ipsec tree.

Now applied to the ipsec-next tree. Thanks everyone for the review!
