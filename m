From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Fix qdisc_graft WRT ingress qdisc
Date: Mon, 14 Sep 2009 17:10:31 -0700 (PDT)
Message-ID: <20090914.171031.144969643.davem@davemloft.net>
References: <20090914083544.GA10444@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60950
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750925AbZIOAKO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 20:10:14 -0400
In-Reply-To: <20090914083544.GA10444@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 14 Sep 2009 08:35:44 +0000

> After the recent mq change using ingress qdisc overwrites dev->qdisc;
> there is also a wrong old qdisc pointer passed to notify_and_destroy.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied, thanks Jarek.

When I did the original TX multiqueue changes I tried to eliminate as
much as possible all of the special ways in which ingress qdiscs are
handled, but this area of how the ingress qdisc pointers are updated
remains.
