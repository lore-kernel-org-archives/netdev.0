From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] sched, cbq: remove OVL_STRATEGY/POLICE
 support
Date: Wed, 08 Jun 2016 11:24:37 -0700 (PDT)
Message-ID: <20160608.112437.1079267186183137035.davem@davemloft.net>
References: <1465400141-29088-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38293 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753815AbcFHSYk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 14:24:40 -0400
In-Reply-To: <1465400141-29088-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Wed,  8 Jun 2016 17:35:37 +0200

> iproute2 does not implement any options that result in the
> TCA_CBQ_OVL_STRATEGY/TCA_CBQ_POLICE attributes being set/used.
> 
> This series removes these two attributes from cbq and makes kernel reject
> them via EOPNOTSUPP in case they are seen.

Please address Eric's struct layout feedback and I'll apply this.
