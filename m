From: Raghuram Kothakota <Raghuram.Kothakota@oracle.com>
Subject: Re: [PATCH net-next 0/2] sunvnet: Packet processing in non-interrupt context.
Date: Thu, 9 Oct 2014 22:13:57 -0700
Message-ID: <D4D411FD-C658-4092-A0AC-68AAA3BD7B3A@oracle.com>
References: <EB9A1CD1-6E1D-409C-89CB-95CC9A5AFC1D@oracle.com> <20141010.003628.646817757614430018.davem@davemloft.net> <960E9AF5-0319-44C7-9A1C-37EAEE52E78E@oracle.com> <20141010.010320.1545286759850518718.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sowmini.varadhan@oracle.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:32845 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750758AbaJJFOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 01:14:04 -0400
In-Reply-To: <20141010.010320.1545286759850518718.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> Linux's TX path it fully parallelized and multiqueue, so you can have
> as many parallel TX threads of control executing over a specific
> device as you can provide TX queues.

Thanks, I guess we need to explore Tx queues as well.

-Raghuram
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
