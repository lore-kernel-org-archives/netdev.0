From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 2.6.22] TCP: Make TCP_RTO_MAX a variable (take 2)
Date: Wed, 29 Aug 2007 09:16:43 -0700
Message-ID: <46D59BEB.1080602@hp.com>
References: <20070712.132448.115910193.davem@davemloft.net> 	<20070828.220447.01366772.noboru.obata.ar@hitachi.com> 	<20070828.133057.107937654.davem@davemloft.net> <20070829.212613.65744831.noboru.obata.ar@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: OBATA Noboru <noboru.obata.ar@hitachi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:45495 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755915AbXH2QR0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Aug 2007 12:17:26 -0400
In-Reply-To: <20070829.212613.65744831.noboru.obata.ar@hitachi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

OBATA Noboru wrote:
> What about another option to let TCP have a notification?
> 
> Can it be a solution if it is standardized?

It would at best be a partial solution which would only work when the 
link failover/whatnot happened on the same system/node as the TCP 
endpoint.  Then it can be some sort of call-back to TCP or the like.

If this failover is out in the middle of the cloud the only way to get a 
notification back to TCP would be by sending it a packet of some sort 
and I don't see that happening.

rick jones
