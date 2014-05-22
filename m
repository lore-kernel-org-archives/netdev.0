From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] bonding: remove rlb_enabled and
 alb_set_mac_address()
Date: Thu, 22 May 2014 17:22:17 -0400 (EDT)
Message-ID: <20140522.172217.1728568872131751930.davem@davemloft.net>
References: <1400764324-23221-1-git-send-email-vfalico@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, andy@greyhouse.net
To: vfalico@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43028 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956AbaEVVWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 17:22:19 -0400
In-Reply-To: <1400764324-23221-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@gmail.com>
Date: Thu, 22 May 2014 15:12:02 +0200

> Currently rlb_enabled works as
> rlb_enabled == (BOND_MODE(bond) == BOND_MODE_ALB)
> so we can always use this verification and drop maintenance of this
> variable.
> 
> alb_set_mac_address(), OTOH, isn't used at all (as the mac changing logic
> is used in other parts), and isn't ever called, so it's safe to remove it
> as well.
> 
> CC: Jay Vosburgh <j.vosburgh@gmail.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> CC: netdev@vger.kernel.org
> Signed-off-by: Veaceslav Falico <vfalico@gmail.com>

I agree with Jay's feedback and that you should:

1) Just go to the new MAC stash scheme in net-next instead of trying
   to fix something you intend to immediately remove.

2) Something to fix this as minimally as possible for 'net' and
   -stable should be done as well.

I'm therefore not applying this series to the tree.

Thanks.
