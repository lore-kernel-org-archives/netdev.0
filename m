From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Re: Possible regression in HTB
Date: Wed, 08 Oct 2008 11:36:49 -0700 (PDT)
Message-ID: <20081008.113649.145879343.davem@davemloft.net>
References: <20081008065551.GB4174@ff.dom.local>
	<200810081006.38840.denys@visp.net.lb>
	<20081008074604.GC4174@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: denys@visp.net.lb, kaber@trash.net, horms@verge.net.au,
	netdev@vger.kernel.org, devik@cdi.cz
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43145
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754718AbYJHShN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 14:37:13 -0400
In-Reply-To: <20081008074604.GC4174@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Wed, 8 Oct 2008 07:46:04 +0000

> pkt_sched: Update qdisc requeue stats in dev_requeue_skb()
> 
> After the last change of requeuing there is no info about such
> incidents in tc stats. This patch updates the counter, but we should
> consider this should differ from previous stats because of additional
> checks preventing to repeat this. On the other hand, previous stats
> didn't include requeuing of gso_segmented skbs.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied to net-next-2.6, thanks Jarek.
