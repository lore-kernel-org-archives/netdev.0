From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] pkt_sched: Fix tx queue selection in tc_modify_qdisc
Date: Tue, 15 Sep 2009 02:53:21 -0700 (PDT)
Message-ID: <20090915.025321.178672469.davem@davemloft.net>
References: <20090914122226.GA14087@ff.dom.local>
	<4AAE85F9.2060600@trash.net>
	<20090914225022.GA13363@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52483
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752470AbZIOJxF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2009 05:53:05 -0400
In-Reply-To: <20090914225022.GA13363@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Tue, 15 Sep 2009 00:50:22 +0200

> -----------------------> (take 2)
> pkt_sched: Fix tx queue selection in tc_modify_qdisc
> 
> After the recent mq change there is the new select_queue qdisc class
> method used in tc_modify_qdisc, but it works OK only for direct child
> qdiscs of mq qdisc. Grandchildren always get the first tx queue, which
> would give wrong qdisc_root etc. results (e.g. for sch_htb as child of
> sch_prio). This patch fixes it by using parent's dev_queue for such
> grandchildren qdiscs. The select_queue method's return type is changed
> BTW.
> 
> With feedback from: Patrick McHardy <kaber@trash.net>
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied, thanks Jarek.
