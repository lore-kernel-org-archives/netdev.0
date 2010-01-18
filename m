From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Mon, 18 Jan 2010 13:00:38 -0800
Message-ID: <20100118130038.77a3adfb@nehalam>
References: <4B4E2F89.2050606@majjas.com>
	<20100113210908.GA3065@del.dom.local>
	<4B4E3834.3000609@majjas.com>
	<4B533A46.9050600@majjas.com>
	<20100117221746.GA3161@del.dom.local>
	<4B53906B.2020608@majjas.com>
	<20100117230531.GC3161@del.dom.local>
	<4B539A0A.2000504@majjas.com>
	<20100118073018.GA6270@ff.dom.local>
	<4B548C6B.10607@majjas.com>
	<20100118204658.GC3157@del.dom.local>
	<4B54CB0D.5070604@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754625Ab0ARVB6@vger.kernel.org>
In-Reply-To: <4B54CB0D.5070604@majjas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 18 Jan 2010 15:56:45 -0500
Michael Breuer <mbreuer@majjas.com> wrote:

> >> 2. The dropped tx packet (DHCP) is a bit harder to recreate, but it
> >> still happens.
> >>        

You might want to use tc filter rule to set priority of DHCP packets
higher. This would cause them to be in a separate queue and eliminate
the problem.

-- 
