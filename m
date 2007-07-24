From: OBATA Noboru <noboru.obata.ar@hitachi.com>
Subject: Re: [PATCH 2.6.22] TCP: Make TCP_RTO_MAX a variable (take 2)
Date: Tue, 24 Jul 2007 22:35:58 +0900 (JST)
Message-ID: <20070724.223558.73364253.noboru.obata.ar@hitachi.com>
References: <20070712.161510.26510093.noboru.obata.ar@hitachi.com>
    <20070712.023710.36923635.davem@davemloft.net> <46969460.3020604@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail9.hitachi.co.jp ([133.145.228.44]:34737 "EHLO
	mail9.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752150AbXGXNgB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 09:36:01 -0400
Received: from mlsv13.hitachi.co.jp (unknown [133.144.234.166])
	by mail9.hitachi.co.jp (Postfix) with ESMTP id 9925637C87
	for <netdev@vger.kernel.org>; Tue, 24 Jul 2007 22:35:59 +0900 (JST)
In-Reply-To: <46969460.3020604@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 2.6.22] TCP: Make TCP_RTO_MAX a variable (take 2)
Date: Thu, 12 Jul 2007 13:51:44 -0700

> > TCP's timeouts are perfectly fine, and the only thing you
> > might be showing above is that the application timeouts
> > are too short or that TCP needs notifications.
> 
> The application timeouts are probably being driven by external desires 
> for a given recovery time.

Agreed.

> TCP notifications don't solve anything unless the links in question are 
> local to the machine on which the TCP endpoint resides.

Agreed.  Thank you for a good explanation.

My original discussion using Dom-0 and Dom-U might be
misleading, but I was trying to say:

* Network failure and recovery(failover) are not necessarily
  visible locally.

  ** Dom-0 vs. Dom-U discussion is just an example of the case
     where a network failure is not visible locally.

  ** For another example, network switches or routers sitting
     somewhere in the middle of route are often duplicated with
     active-standby setting today.

* Quick response (retransmission) of TCP upon a recovery of such
  invisible devices as well is desired.

* If the failure and recovery are not visible locally, TCP
  notifications do not help.

Regards,

-- 
OBATA Noboru (noboru.obata.ar@hitachi.com)
