From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] netpoll: fix smatch warnings in netpoll core code
Date: Wed, 13 Feb 2013 12:03:54 -0500
Message-ID: <20130213170354.GB26539@hmsreliant.think-freely.org>
References: <1360773162-11949-1-git-send-email-nhorman@tuxdriver.com>
 <20130213.115720.1571411485926797138.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dan.carpenter@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38395 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760039Ab3BMREE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2013 12:04:04 -0500
Content-Disposition: inline
In-Reply-To: <20130213.115720.1571411485926797138.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 13, 2013 at 11:57:20AM -0500, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Wed, 13 Feb 2013 11:32:42 -0500
> 
> > Dan Carpenter contacted me with some notes regarding some smatch warnings in the
> > netpoll code, some of which I introduced with my recent netpoll locking fixes,
> > some which were there prior.   Specifically they were:
> > 
> > net-next/net/core/netpoll.c:243 netpoll_poll_dev() warn: inconsistent
> >   returns mutex:&ni->dev_lock: locked (213,217) unlocked (210,243)
> > net-next/net/core/netpoll.c:706 netpoll_neigh_reply() warn: potential
> >   pointer math issue ('skb_transport_header(send_skb)' is a 128 bit pointer)
> > 
> > This patch corrects the locking imbalance (the first error), and adds some
> > parenthesis to correct the second error.  Tested by myself. Applies to net-next
> > 
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> 
> Applied, thanks Neil.
> 
> Again, please specify in the Subject line the destination tree.
Sorry dave, I specified net-next in the changelog, didn't realize you preferred
it in the subject.
Neil

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
