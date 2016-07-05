From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bonding: fix enslavement slave link notifications
Date: Tue, 05 Jul 2016 12:13:10 -0700 (PDT)
Message-ID: <20160705.121310.808927448900147837.davem@davemloft.net>
References: <1467709787-30993-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
	gospo@cumulusnetworks.com, jiri@mellanox.com, avivh@mellanox.com
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40684 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752003AbcGETNQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 15:13:16 -0400
In-Reply-To: <1467709787-30993-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Tue,  5 Jul 2016 12:09:47 +0300

> From: Aviv Heller <avivh@mellanox.com>
> 
> Currently, link notifications are not sent by
> bond_set_slave_link_state() upon enslavement if
> the slave is enslaved when up.
> 
> This happens because slave->link default init value
> is 0, which is the same as BOND_LINK_UP, resulting
> in bond_set_slave_link_state() ignoring this transition.
> 
> This patch sets the default value of slave->link to
> BOND_LINK_NOCHANGE, assuring it will count as a state
> transition and thus trigger notification logic.
> 
> Signed-off-by: Aviv Heller <avivh@mellanox.com>
> Reviewed-by: Jiri Pirko <jiri@mellanox.com>
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>

Applied.
