From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3 v2 net-next] pkt_sched: sch_htb: Warn on too many
 events.
Date: Sun, 01 Feb 2009 01:13:34 -0800 (PST)
Message-ID: <20090201.011334.86122260.davem@davemloft.net>
References: <20090128125230.GA6282@ff.dom.local>
	<49808544.5010304@trash.net>
	<20090130101701.GA8882@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, devik@cdi.cz, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40651
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751673AbZBAJNh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Feb 2009 04:13:37 -0500
In-Reply-To: <20090130101701.GA8882@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Fri, 30 Jan 2009 10:17:01 +0000

> pkt_sched: sch_hfsc: sch_htb: Add non-work-conserving warning handler.
> 
> Patrick McHardy <kaber@trash.net> suggested:
> > How about making this flag and the warning message (in a out-of-line
> > function) globally available? Other qdiscs (f.i. HFSC) can't deal with
> > inner non-work-conserving qdiscs as well.
> 
> This patch uses qdisc->flags field of "suspected" child qdisc.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied.
