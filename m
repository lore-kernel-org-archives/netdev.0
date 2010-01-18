From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Mon, 18 Jan 2010 23:08:14 +0100
Message-ID: <20100118220814.GG3157@del.dom.local>
References: <20100117221746.GA3161@del.dom.local>
 <4B53906B.2020608@majjas.com>
 <20100117230531.GC3161@del.dom.local>
 <4B539A0A.2000504@majjas.com>
 <20100118073018.GA6270@ff.dom.local>
 <4B548C6B.10607@majjas.com>
 <20100118204658.GC3157@del.dom.local>
 <4B54CB0D.5070604@majjas.com>
 <20100118212516.GE3157@del.dom.local>
 <4B54D50C.90608@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755230Ab0ARWIW@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B54D50C.90608@majjas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 18, 2010 at 04:39:24PM -0500, Michael Breuer wrote:
> Some output from tc -s qdisc:
...
> After the conclusion of the test:
> qdisc pfifo_fast 0: dev eth0 root refcnt 2 bands 3 priomap  1 2 2 2
> 1 2 0 0 1 1 1 1 1 1 1 1
>  Sent 244900497 bytes 3416350 pkt (dropped 0, overlimits 0 requeues 0)
>  rate 0bit 0pps backlog 0b 0p requeues 0
> qdisc pfifo_fast 0: dev eth1 root refcnt 2 bands 3 priomap  1 2 2 2
> 1 2 0 0 1 1 1 1 1 1 1 1
>  Sent 564380 bytes 4708 pkt (dropped 0, overlimits 0 requeues 0)
>  rate 0bit 0pps backlog 0b 0p requeues 0

Great!

> 
> 
> During the test, 8.9GB received; 232.9MB sent).
> 
> I also connected a second device through the wifi router. I was able
> to ping that device w/o loss while DHCP packets were being dropped
> to the other connected device.

Could you remind us if the problem is always with this first device?
Btw, I wonder if you could test it skipping the (HP?) switch?

Jarek P.
