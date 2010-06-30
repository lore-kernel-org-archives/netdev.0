From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] bonding: check if clients MAC addr has changed
Date: Wed, 30 Jun 2010 13:52:49 -0700 (PDT)
Message-ID: <20100630.135249.73361702.davem@davemloft.net>
References: <1277835879-26834-1-git-send-email-fleitner@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net, fubar@us.ibm.com,
	netdev@vger.kernel.org, gospo@redhat.com
To: fleitner@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38284
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752867Ab0F3Uwh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 16:52:37 -0400
In-Reply-To: <1277835879-26834-1-git-send-email-fleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fleitner@redhat.com>
Date: Tue, 29 Jun 2010 15:24:39 -0300

> When two systems using bonding devices in adaptive load
> balancing (ALB) communicates with each other, an endless
> ping-pong of ARP replies starts between these two systems.
> 
> What happens? In the ALB mode, bonding driver keeps track
> of each client connected in a hash table, so it can do the
> receive load balancing (RLB). This hash table is updated
> when an ARP reply is received, then it scans for the client
> entry, updates its MAC address and flag it to be announced
> later. Therefore, two seconds later, the alb monitor runs
> and send for each updated client entry two ARP replies
> updating this specific client. The same process happens on
> the receiving system, causing the endless ping-pong of arp
> replies.
> 
> See more information including the relevant functions below:
 ...
> Signed-off-by: Flavio Leitner <fleitner@redhat.com>
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Applied, thanks.

Probably one of the best networking commit log messages I've seen in a
long time.  Nice work.
