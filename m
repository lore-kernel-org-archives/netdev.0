From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2 2/2] net: introduce
 netif_addr_lock_nested() and call if when appropriate
Date: Mon, 09 Jan 2012 12:47:23 -0800 (PST)
Message-ID: <20120109.124723.2024034017916493404.davem@davemloft.net>
References: <1326125915-2711-2-git-send-email-jpirko@redhat.com>
	<20120109163654.GC2114@minipsycho.brq.redhat.com>
	<1326136028.2725.0.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35840 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933241Ab2AIUr1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2012 15:47:27 -0500
In-Reply-To: <1326136028.2725.0.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 9 Jan 2012 19:07:08 +0000

> On Mon, 2012-01-09 at 17:36 +0100, Jiri Pirko wrote:
>> dev_uc_sync() and dev_mc_sync() are acquiring netif_addr_lock for
>> destination device of synchronization. Since netif_addr_lock is already
>> held at the time for source device, this triggers depmod deathlock
>> warning.
> [...]
> 
> I think you mean '...lockdep deadlock warning'?

Applied with this wording fixed.
