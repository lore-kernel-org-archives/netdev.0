From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] aoe: remove dev_base_lock use from aoecmd_cfg_pkts()
Date: Mon, 08 Nov 2010 13:43:28 -0800 (PST)
Message-ID: <20101108.134328.70192293.davem@davemloft.net>
References: <1288350929.2560.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ecashin@coraid.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57749
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755434Ab0KHVnE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 16:43:04 -0500
In-Reply-To: <1288350929.2560.16.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 29 Oct 2010 13:15:29 +0200

> dev_base_lock is the legacy way to lock the device list, and is planned
> to disappear. (writers hold RTNL, readers hold RCU lock)
> 
> Convert aoecmd_cfg_pkts() to RCU locking.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
