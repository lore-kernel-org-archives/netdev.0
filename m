From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] pkt_sched: Fix sch_sfq vs tc_modify_qdisc oops
Date: Wed, 11 Aug 2010 01:37:50 -0700 (PDT)
Message-ID: <20100811.013750.193698154.davem@davemloft.net>
References: <20100811083101.GA10126@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, kaber@trash.net,
	franchoze@yandex.ru
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41309
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753153Ab0HKIhd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Aug 2010 04:37:33 -0400
In-Reply-To: <20100811083101.GA10126@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Wed, 11 Aug 2010 08:31:02 +0000

> After more investigation I've found sch_sfq is still vulnerable
> because off its missing class handlers. Here is an oops as
> proof of the concept, and a patch below. This patch should be
> considered for stable (without following 2/2 patch).

Thanks Jarek, both applied to net-2.6 and the first queued up
for -stable.
