From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] net/mlx4_core: mlx4_init_slave() shouldn't
 access comm channel before PF is ready
Date: Thu, 06 Mar 2014 17:09:27 -0500 (EST)
Message-ID: <20140306.170927.196605336074788079.davem@davemloft.net>
References: <CAJZOPZKdxmZ1NBKxnSeAnQv-F=e0zQBsjTON64RE67EitkySLQ@mail.gmail.com>
	<20140306.161258.1157292873686161603.davem@davemloft.net>
	<CAJZOPZKfZ3Lp7XwasR19M1QC+5+ksQst8SORAxi2A7NVeHp7qg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ddutile@redhat.com, amirv@mellanox.com, ogerlitz@mellanox.com,
	yevgenyp@mellanox.com, Narendra_K@dell.com,
	Sreekanth_Reddy@dell.com, netdev@vger.kernel.org,
	andy@greyhouse.net
To: or.gerlitz@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34025 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751650AbaCFWJa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 17:09:30 -0500
In-Reply-To: <CAJZOPZKfZ3Lp7XwasR19M1QC+5+ksQst8SORAxi2A7NVeHp7qg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <or.gerlitz@gmail.com>
Date: Thu, 6 Mar 2014 23:58:19 +0200

> So... we were thinking that there is a mechanism that causes them to
> retry that init as long as they return -EPROBE_DEFER or they succeed,
> isn't that the case?

Indeed.  When the PF returns from it's probe, all VFs that deferred
will retry.

Both patches applied, thanks.
