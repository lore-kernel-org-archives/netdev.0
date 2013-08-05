From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: remove locking from
 bond_set_rx_mode()
Date: Mon, 05 Aug 2013 12:23:12 -0700 (PDT)
Message-ID: <20130805.122312.1354065558935534703.davem@davemloft.net>
References: <1375707366-6762-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	nikolay@redhat.com
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48409 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752693Ab3HETXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 15:23:13 -0400
In-Reply-To: <1375707366-6762-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Mon,  5 Aug 2013 14:56:06 +0200

> We're already protected by RTNL lock, so nothing can happen to bond/its
> slaves, and thus the locking is useless here (both bond->lock and
> bond->curr_active_slave).
> 
> Also, add ASSERT_RTNL() both to bond_set_rx_mode() and bond_hw_addr_swap()
> to catch possible uses of it without RTNL locking.
> 
> This patch also saves us from a lockdep false-positive in
> bond_set_rx_mode() vs bond_hw_addr_swap().
> 
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> CC: Nikolay Aleksandrov <nikolay@redhat.com>
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

Applied.
