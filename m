From: OBATA Noboru <noboru.obata.ar@hitachi.com>
Subject: Re: [PATCH 2.6.22] TCP: Make TCP_RTO_MAX a variable (take 2)
Date: Thu, 30 Aug 2007 21:24:09 +0900 (JST)
Message-ID: <20070830.212409.91277848.noboru.obata.ar@hitachi.com>
References: <20070828.133057.107937654.davem@davemloft.net>
    <20070829.212613.65744831.noboru.obata.ar@hitachi.com>
    <46D59BEB.1080602@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail9.hitachi.co.jp ([133.145.228.44]:57568 "EHLO
	mail9.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753958AbXH3MYL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2007 08:24:11 -0400
Received: from mlsv13.hitachi.co.jp (unknown [133.144.234.166])
	by mail9.hitachi.co.jp (Postfix) with ESMTP id 263B037C89
	for <netdev@vger.kernel.org>; Thu, 30 Aug 2007 21:24:10 +0900 (JST)
In-Reply-To: <46D59BEB.1080602@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Rick,

From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 2.6.22] TCP: Make TCP_RTO_MAX a variable (take 2)
Date: Wed, 29 Aug 2007 09:16:43 -0700

> OBATA Noboru wrote:
> > What about another option to let TCP have a notification?
> > 
> > Can it be a solution if it is standardized?
> 
> It would at best be a partial solution which would only work when the 
> link failover/whatnot happened on the same system/node as the TCP 
> endpoint.  Then it can be some sort of call-back to TCP or the like.

I understood that the IETF document pointed by John has such a
limitation.

> If this failover is out in the middle of the cloud the only way to get a 
> notification back to TCP would be by sending it a packet of some sort 
> and I don't see that happening.

Agreed.

I learned that, in practice, the route monitoring by probe
packets (ICMP or others) is used to detect a failure along the
route to an important host.

This monitoring apparently doesn't scale and so its use is
limited to the route to an important host, but practices show
that it is quite effective in monitoring.

I am now wondering about a TCP notification mechanism combined
with the route monitoring.

Regards,

-- 
OBATA Noboru (noboru.obata.ar@hitachi.com)
