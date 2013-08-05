From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next] bonding: remove locking from bond_set_rx_mode()
Date: Mon, 05 Aug 2013 15:45:48 +0200
Message-ID: <51FFAC8C.20205@redhat.com>
References: <1375707366-6762-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21068 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752645Ab3HENtW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Aug 2013 09:49:22 -0400
In-Reply-To: <1375707366-6762-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/05/2013 02:56 PM, Veaceslav Falico wrote:
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
> ---

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
