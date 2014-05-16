From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 0/9] bonding: simple macro cleanup
Date: Fri, 16 May 2014 16:35:13 -0400 (EDT)
Message-ID: <20140516.163513.1719431594454182990.davem@davemloft.net>
References: <1400182799-22737-1-git-send-email-vfalico@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, andy@greyhouse.net
To: vfalico@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49134 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751881AbaEPUfP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 16:35:15 -0400
In-Reply-To: <1400182799-22737-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@gmail.com>
Date: Thu, 15 May 2014 21:39:50 +0200

> Trivial patchset that converts most of the bonding's macros into inline
> functions. It introduces only one macro, BOND_MODE(), which is just
> bond->params.mode, better to write/understand/remember.
> 
> The only real change is the removal of IFF_UP verification, which always
> came in pair with && netif_running(), and is though useless, as it's always
> IFF_UP when LINK_STATE_RUNNING.
> 
> v2->v3: fix 3/9 to actually invert bond_mode_uses_arp() and add
> 	bond_uses_arp() alongside bond_mode_uses_arp()
> v1->v2: use inlined functions instead of macros.

Series applied, thank you.
