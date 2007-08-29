From: OBATA Noboru <noboru.obata.ar@hitachi.com>
Subject: Re: [PATCH 2.6.22] TCP: Make TCP_RTO_MAX a variable (take 2)
Date: Wed, 29 Aug 2007 21:26:13 +0900 (JST)
Message-ID: <20070829.212613.65744831.noboru.obata.ar@hitachi.com>
References: <20070712.132448.115910193.davem@davemloft.net>
    <20070828.220447.01366772.noboru.obata.ar@hitachi.com>
    <20070828.133057.107937654.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.hitachi.co.jp ([133.145.228.42]:42801 "EHLO
	mail7.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756867AbXH2M0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 08:26:16 -0400
Received: from mlsv16.hitachi.co.jp (unknown [133.144.234.166])
	by mail7.hitachi.co.jp (Postfix) with ESMTP id D2C4437B19
	for <netdev@vger.kernel.org>; Wed, 29 Aug 2007 21:26:14 +0900 (JST)
In-Reply-To: <20070828.133057.107937654.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.22] TCP: Make TCP_RTO_MAX a variable (take 2)
Date: Tue, 28 Aug 2007 13:30:57 -0700 (PDT)

> From: OBATA Noboru <noboru.obata.ar@hitachi.com>
> Date: Tue, 28 Aug 2007 22:04:47 +0900 (JST)
> 
> > (1) Make the application timeouts longer.  (Steve has shown that
> >     making an application timeouts twice the failover detection
> >     timeout would be a solution.)
> 
> This is the only feasible solution to your problem.

What about another option to let TCP have a notification?

Can it be a solution if it is standardized?

-- 
OBATA Noboru (noboru.obata.ar@hitachi.com)
