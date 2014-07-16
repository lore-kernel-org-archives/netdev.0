From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/4] bonding: rcu cleanups
Date: Tue, 15 Jul 2014 17:50:41 -0700 (PDT)
Message-ID: <20140715.175041.1779643875444299705.davem@davemloft.net>
References: <1405432616-12414-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
	andy@greyhouse.net, nikolay@redhat.com, maheshb@google.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46186 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759950AbaGPAum (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 20:50:42 -0400
In-Reply-To: <1405432616-12414-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Tue, 15 Jul 2014 06:56:52 -0700

> RCU was added to bonding in linux-3.12 but lacked proper sparse annotations.
> 
> Using __rcu annotation actually helps to spot all accesses to
> bond->curr_active_slave & cond->current_arp_slave
> are correctly protected, with full sparse & LOCKDEP support.
> 
> Lets clean the code.

Series applied, thanks a lot Eric.
