From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 -next] sched: remove NET_XMIT_POLICED
Date: Sat, 11 Jun 2016 15:54:07 -0700 (PDT)
Message-ID: <20160611.155407.1424553523659683009.davem@davemloft.net>
References: <1465641964-12342-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40587 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752758AbcFKWyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2016 18:54:13 -0400
In-Reply-To: <1465641964-12342-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Sat, 11 Jun 2016 12:46:04 +0200

> sch_atm returns this when TC_ACT_SHOT classification occurs.
> 
> But all other schedulers that use tc_classify
> (htb, hfsc, drr, fq_codel ...) return NET_XMIT_SUCCESS | __BYPASS
> in this case so just do that in atm.

Yes, but it's been like this for two decades.

One of the points of my reply to the previous version of this
patch is that indeed it is explicitly returned, intentionally.
