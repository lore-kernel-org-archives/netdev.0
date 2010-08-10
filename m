From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netpoll: use non-BH variant of RCU
Date: Tue, 10 Aug 2010 16:31:17 -0700 (PDT)
Message-ID: <20100810.163117.241919476.davem@davemloft.net>
References: <1281471924-2237-1-git-send-email-linville@tuxdriver.com>
	<20100810204358.GA1076@gondor.apana.org.au>
	<20100810211932.GG2379@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, linville@tuxdriver.com,
	netdev@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41417
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757887Ab0HJXa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 19:30:58 -0400
In-Reply-To: <20100810211932.GG2379@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Tue, 10 Aug 2010 14:19:32 -0700

> Your suggestion of providing another API rcu_read_lock_irqsoff()
> and rcu_read_unlock_irqsoff() is the best I can think of right offhand.
> 
> What tree/commit do you need the patch against?

Linus's tree is fine for this.

But we need this fix for 2.6.35-stable too.  Herbert would
you object to putting John's more simple fix there?

John, when referencing other commits in commit messages,
please provide the SHA1 ID as well as the commit message
header line.

Thanks.
