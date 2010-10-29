From: Ed Cashin <ecashin@coraid.com>
Subject: Re: [PATCH] aoe: remove dev_base_lock use from aoecmd_cfg_pkts()
Date: Fri, 29 Oct 2010 13:18:12 -0400
Message-ID: <6390F3B7-6E76-4556-B1C8-E0C25D861880@coraid.com>
References: <1288350929.2560.16.camel@edumazet-laptop>
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from baron.coraid.com ([12.51.113.4]:62885 "EHLO coraid.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756837Ab0J2RfP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Oct 2010 13:35:15 -0400
In-Reply-To: <1288350929.2560.16.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet writes :

> dev_base_lock is the legacy way to lock the device list, and is planned
> to disappear. (writers hold RTNL, readers hold RCU lock)
> 
> Convert aoecmd_cfg_pkts() to RCU locking.


Thanks.

-- 
  Ed Cashin
  ecashin@coraid.com

