From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Use rcu_assign_pointer() to change
 dev_queue->qdisc
Date: Wed, 27 Aug 2008 02:22:37 -0700 (PDT)
Message-ID: <20080827.022237.105102217.davem@davemloft.net>
References: <20080827085927.GA7060@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48154
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753237AbYH0JWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 05:22:42 -0400
In-Reply-To: <20080827085927.GA7060@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Wed, 27 Aug 2008 08:59:27 +0000

> pkt_sched: Use rcu_assign_pointer() to change dev_queue->qdisc
> 
> These pointers are RCU protected, so proper primitives should be used.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Looks good, applied, thanks Jarek.
