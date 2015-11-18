From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] hdlc: fix null-deref on allocation failure
Date: Wed, 18 Nov 2015 15:06:17 -0500 (EST)
Message-ID: <20151118.150617.2029772013530226874.davem@davemloft.net>
References: <20151117142606.4a0ca2d1@samsung9>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, netdev@vger.kernel.org
To: shemming@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53201 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755911AbbKRUGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 15:06:19 -0500
In-Reply-To: <20151117142606.4a0ca2d1@samsung9>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemming@brocade.com>
Date: Tue, 17 Nov 2015 14:26:06 -0800

> If alloc_netdev() failed and return NULL, then the next instruction
> would dereference it. Found by Coverity.
> 
> Compile tested only. Not sure if anyone still uses this driver
> (or the whole WAN subsystem).
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
