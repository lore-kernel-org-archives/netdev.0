From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 2/3] netpoll: rework skb transmit queue
Date: Fri, 20 Oct 2006 23:16:03 +0200
Message-ID: <200610202316.03940.ak@suse.de>
References: <20061020.134209.85688168.davem@davemloft.net> <200610202301.29859.ak@suse.de> <20061020.140859.95896187.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:38366 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S2992708AbWJTVQK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 17:16:10 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061020.140859.95896187.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 20 October 2006 23:08, David Miller wrote:
> From: Andi Kleen <ak@suse.de>
> Date: Fri, 20 Oct 2006 23:01:29 +0200
> 
> > netpoll always played a little fast'n'lose with various locking rules.
> 
> The current code is fine, it never reenters ->poll, because it
> maintains a "->poll_owner" which it checks in netpoll_send_skb()
> before trying to call back into ->poll.

I was more thinking of reentry of the interrupt handler in 
the driver etc. A lot of them also do printk, but that is fortunately
caught higher level.

-Andi
