From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netns: Don't receive new packets in a dead network
 namespace.
Date: Fri, 20 Jun 2008 22:17:26 -0700 (PDT)
Message-ID: <20080620.221726.82764674.davem@davemloft.net>
References: <20080620204943.GA5068@martell.zuzino.mipt.ru>
	<m1k5gjej5q.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, den@openvz.org, xemul@openvz.org,
	dlezcano@fr.ibm.com, benjamin.thery@bull.net, adobriyan@gmail.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46668
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751122AbYFUFR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jun 2008 01:17:26 -0400
In-Reply-To: <m1k5gjej5q.fsf@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 20 Jun 2008 17:17:05 -0700

> Alexey Dobriyan <adobriyan@gmail.com> writes:
> > Subject: ICMP sockets destruction vs ICMP packets oops
 ...
> Receiving packets while we are cleaning up a network namespace is a
> racy proposition. It is possible when the packet arrives that we have
> removed some but not all of the state we need to fully process it.  We
> have the choice of either playing wack-a-mole with the cleanup routines
> or simply dropping packets when we don't have a network namespace to
> handle them.
> 
> Since the check looks inexpensive in netif_receive_skb let's just
> drop the incoming packets.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Because of Alexey's positive test report, and the fact that it
looks OK to me, I'm adding this to net-2.6

Thanks.
