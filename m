From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4i : remove spurious use of rcu
Date: Sat, 02 Aug 2014 20:34:27 -0700 (PDT)
Message-ID: <20140802.203427.334773977447118350.davem@davemloft.net>
References: <1407019844-21148-1-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hch@infradead.org, kxie@chelsio.com,
	manojmalviya@chelsio.com, aaron.lu@intel.com,
	xiyou.wangcong@gmail.com, fengguang.wu@intel.com
To: anish@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51369 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754537AbaHCDea (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Aug 2014 23:34:30 -0400
In-Reply-To: <1407019844-21148-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anish Bhatt <anish@chelsio.com>
Date: Sat,  2 Aug 2014 15:50:44 -0700

> As pointed out by the intel guys, there is no need to hold rcu read lock in
> cxgbi_inet6addr_handler(), this patch removes it.
> 
> Fixes: 759a0cc5a3e1 ("cxgb4i: Add ipv6 code to driver, call into libcxgbi ipv6
> api")
> Signed-off-by: Anish Bhatt <anish@chelsio.com>

Applied, thanks.
