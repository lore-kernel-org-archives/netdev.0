From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tipc: fix potential null pointer dereference in the
 nla_data function
Date: Fri, 10 Jun 2016 23:23:46 -0700 (PDT)
Message-ID: <20160610.232346.782087200889412685.davem@davemloft.net>
References: <4b00b274-d144-2809-fa86-1ea38d913fd5@gmail.com>
	<a692a179-6f59-fdbb-9c49-e943677fce43@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, ying.xue@windriver.com,
	netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: sploving1@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35204 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751115AbcFKGXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2016 02:23:47 -0400
In-Reply-To: <a692a179-6f59-fdbb-9c49-e943677fce43@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Baozeng Ding <sploving1@gmail.com>
Date: Fri, 10 Jun 2016 10:26:59 +0800

> Before calling the nla_data function, make sure the argument is not null.
> Fix potential null pointer dereference vulnerability for this.
> 
> Signed-off-by: Baozeng Ding <sploving1@gmail.com>

TIPC maintainers, please review.
