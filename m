From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tipc: fix potential null pointer dereferences in
 some compat functions
Date: Wed, 25 May 2016 12:34:08 -0700 (PDT)
Message-ID: <20160525.123408.512349398576210042.davem@davemloft.net>
References: <4b00b274-d144-2809-fa86-1ea38d913fd5@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, ying.xue@windriver.com,
	netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: sploving1@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42411 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750920AbcEYTeK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2016 15:34:10 -0400
In-Reply-To: <4b00b274-d144-2809-fa86-1ea38d913fd5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Baozeng Ding <sploving1@gmail.com>
Date: Tue, 24 May 2016 22:33:24 +0800

> Before calling the nla_parse_nested function, make sure the pointer to the
> attribute is not null. This patch fixes several potential null pointer
> dereference vulnerabilities in the tipc netlink functions.
> 
> Signed-off-by: Baozeng Ding <sploving1@gmail.com>
> ---
> v2: declare local variable as reverse christmas tree format and make the commit
> log fit in 80 columns

Looks good, applied, thanks.
