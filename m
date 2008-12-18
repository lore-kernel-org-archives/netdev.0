From: David Miller <davem@davemloft.net>
Subject: Re: net-next: broken IP_PKTINFO
Date: Wed, 17 Dec 2008 19:34:06 -0800 (PST)
Message-ID: <20081217.193406.102253657.davem@davemloft.net>
References: <20081124.210038.90767194.davem@davemloft.net>
	<492C919E.3050108@cosmosbay.com>
	<1229513101.3685.57.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, andi@firstfloor.org, netdev@vger.kernel.org
To: markmc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42390
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752051AbYLRDeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 22:34:04 -0500
In-Reply-To: <1229513101.3685.57.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark McLoughlin <markmc@redhat.com>
Date: Wed, 17 Dec 2008 11:25:01 +0000

> On Wed, 2008-11-26 at 01:00 +0100, Eric Dumazet wrote:
> 
> > [PATCH] net: release skb->dst in sock_queue_rcv_skb()
 ...
> IP_PKTINFO cmsg data is one post-queueing user:

Eric, we'll need to rever this change I think.
