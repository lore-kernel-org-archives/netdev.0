From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TIPC: fix printk warning
Date: Tue, 03 Oct 2006 16:25:44 -0700 (PDT)
Message-ID: <20061003.162544.125897847.davem@davemloft.net>
References: <20061001162413.GA8000@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp-2
Content-Transfer-Encoding: 7bit
Cc: per.liden@ericsson.com, jon.maloy@ericsson.com,
	allan.stephens@windriver.com, akpm@osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:4066
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030680AbWJCXZl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Oct 2006 19:25:41 -0400
To: jeff@garzik.org
In-Reply-To: <20061001162413.GA8000@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>
Date: Sun, 1 Oct 2006 12:24:13 -0400

> gcc spits out this warning:
> 
> net/tipc/link.c: In function $,1rx(Blink_retransmit_failure$,1ry(B:
> net/tipc/link.c:1669: warning: cast from pointer to integer of different
> size
> 
> More than a little bit ugly, storing integers in void*, but at least the
> code is correct, unlike some of the more crufty Linux kernel code found
> elsewhere.
> 
> Rather than having two casts to massage the value into u32, it's easier
> just to have a single cast and use "%lu", since it's just a printk.
> 
> Signed-off-by: Jeff Garzik <jeff@garzik.org>

Applied, thanks Jeff.
