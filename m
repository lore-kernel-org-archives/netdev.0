From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Tue, 19 Jan 2010 08:41:20 +0000
Message-ID: <20100119084120.GA6366@ff.dom.local>
References: <20100118073018.GA6270@ff.dom.local> <4B548C6B.10607@majjas.com> <20100118204658.GC3157@del.dom.local> <4B54CB0D.5070604@majjas.com> <20100118212516.GE3157@del.dom.local> <4B54D50C.90608@majjas.com> <20100118220814.GG3157@del.dom.local> <20100118221747.GH3157@del.dom.local> <4B54E4EF.8080602@majjas.com> <4B554730.6090000@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755491Ab0ASIla@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B554730.6090000@majjas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 19, 2010 at 12:46:24AM -0500, Michael Breuer wrote:
> So net-net, as far as my TX packet loss issue, sky2 is in the clear. If  
> something on the linux side should be informing the switch about  
> something then there may still be an issue. If the wifi router should be  
> doing something differently, then it's unfortunately likely a 2.4.37  
> kernel issue (That's what dd-wrt is using).

IMHO until there is no proof from a sniffer or some regs dumps the
switch and the router are more suspicious than your NIC or linux box.
Then debugging these other things isn't so much interesting from my
POV ;-)

Anyway, if you only want to get it working (instead of debugging),
it seems you might try moving the dhcp server to the router or maybe
even using two separate servers with their pools - unless I missed
something in your config.

Jarek P.
