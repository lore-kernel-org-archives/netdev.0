From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] tipc: cleanup topology server
Date: Mon, 04 May 2015 15:05:13 -0400 (EDT)
Message-ID: <20150504.150513.980672757479761618.davem@davemloft.net>
References: <1430707008-11141-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Paul.Gortmaker@windriver.com,
	erik.hugne@ericsson.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38134 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751360AbbEDTFP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 15:05:15 -0400
In-Reply-To: <1430707008-11141-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Mon, 4 May 2015 10:36:43 +0800

> Not only function names declared in subscr.c are very confused, but
> also topology server's locking policy is not designed very well, for
> instance, usually leading to panic in some special corner cases.
> 
> In this series, we attempt to eliminate the confusion of function names
> and simplify topology server's locking policy to solve above mentioned
> issues. More importantly, the change will make relevant code easily
> understandable and maintainable.

Series applied, thanks.

I think the "void *" cast of the return value from
tipc_subscrb_connect_cb() is completely unnecessary.  All casts to and
from void are implicit in C.
