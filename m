From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net: reintroduce missing rcu_assign_pointer() calls
Date: Thu, 12 Jan 2012 07:47:51 -0800
Message-ID: <20120112074751.7c870323@nehalam.linuxnetplumber.net>
References: <1326376603.2950.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1326379292.2950.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41495 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754061Ab2ALPry (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jan 2012 10:47:54 -0500
In-Reply-To: <1326379292.2950.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Jan 2012 15:41:32 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> commit a9b3cd7f32 (rcu: convert uses of rcu_assign_pointer(x, NULL) to
> RCU_INIT_POINTER) did a lot of incorrect changes, since it did a
> complete conversion of rcu_assign_pointer(x, y) to RCU_INIT_POINTER(x,
> y).
> 

Agreed. Looks like the script was too aggressive.
