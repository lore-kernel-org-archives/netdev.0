From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH take2] pkt_sched: Fix TX state checking in qdisc_run()
Date: Sat, 20 Sep 2008 22:18:57 -0700 (PDT)
Message-ID: <20080920.221857.263162197.davem@davemloft.net>
References: <20080919103225.GB9135@ff.dom.local>
	<20080919144450.GA2646@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.duyck@gmail.com, alexander.h.duyck@intel.com,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	kaber@trash.net
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48794
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750743AbYIUFTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2008 01:19:09 -0400
In-Reply-To: <20080919144450.GA2646@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Fri, 19 Sep 2008 16:44:50 +0200

> pkt_sched: Fix TX state checking in qdisc_run()
> 
> Current check wrongly uses the state of the first tx queue for all tx
> queues in case of non-default qdiscs. This patch brings back per dev
> __LINK_STATE_XOFF flag, which is set when all tx queues are stopped.
> This check is needed in qdisc_run() to avoid useless __netif_schedule()
> calls. The wrongness of this check was first noticed by Herbert Xu.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

I'm dropping this and the patches in the ->smart_requeue thread as well.

It simply isn't crystal clear how to proceed at this point.
