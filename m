From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 2.6.22] TCP: Make TCP_RTO_MAX a variable (take 2)
Date: Thu, 12 Jul 2007 13:51:44 -0700
Message-ID: <46969460.3020604@hp.com>
References: <20070712.161510.26510093.noboru.obata.ar@hitachi.com> <20070712.023710.36923635.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: noboru.obata.ar@hitachi.com, shemminger@linux-foundation.org,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:54392 "EHLO palrel13.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758774AbXGLUwY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jul 2007 16:52:24 -0400
In-Reply-To: <20070712.023710.36923635.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 
> TCP's timeouts are perfectly fine, and the only thing you
> might be showing above is that the application timeouts
> are too short or that TCP needs notifications.

The application timeouts are probably being driven by external desires 
for a given recovery time.

TCP notifications don't solve anything unless the links in question are 
local to the machine on which the TCP endpoint resides.

So, it seems that what this is really saying is that in the context of 
Linux at least, TCP is not a suitable protocol to be used in situations 
where a fast detection/recovery is desired.

Does that pretty much sum it up?

rick jones
