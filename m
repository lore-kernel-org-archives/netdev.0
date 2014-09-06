From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v6 4/4] tg3: Fix tx_pending checks for tg3_tso_bug
Date: Fri, 05 Sep 2014 17:13:06 -0700 (PDT)
Message-ID: <20140905.171306.1460013939580748402.davem@davemloft.net>
References: <1409880647-14887-5-git-send-email-bpoirier@suse.de>
	<1409960135.18724.33.camel@prashant>
	<1409961810.26422.149.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: prashant@broadcom.com, bpoirier@suse.de, mchan@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1409961810.26422.149.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 05 Sep 2014 17:03:30 -0700

> Instead of this private helper (and pretty limited one btw), we could
> add a core function, that would build skbs with order-0 fragments.
> 
> Instead of skb_linearize(), I guess many call sites could instead use
> this new helper.
> 
> Because as you said, skb_linearize() of one 64KB GSO packet can ask
> order-5 allocations, and this generally does not work reliably.

xen-netback could make use of this helper too.
