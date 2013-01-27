From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [RFC:] struct net_device_ops: Add function pointer to fill
 device specific ndisc information
Date: Sun, 27 Jan 2013 15:43:32 +0100
Message-ID: <20130127154332.6b5730f9@stein>
References: <50FC2EE4.3080705@gmail.com>
	<50FC3BB1.4070005@linux-ipv6.org>
	<50FC6068.3020302@gmail.com>
	<50FCA825.7070609@linux-ipv6.org>
	<50FCDF5D.3060300@gmail.com>
	<20130121083957.6e2c5a68@stein>
	<50FD962B.8020500@gmail.com>
	<50FD9DB7.60802@linux-ipv6.org>
	<50FDB039.2070604@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev <netdev@vger.kernel.org>,
	linux1394-devel@lists.sourceforge.net,
	David Miller <davem@davemloft.net>
To: stephan.gatzka@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:55878 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755650Ab3A0Onu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jan 2013 09:43:50 -0500
In-Reply-To: <50FDB039.2070604@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jan 21 Stephan Gatzka wrote:
> 
> >> Full ack. And that's the reason why I feel very uncomfortable with a Yoshifujis hardware address extensions by fifo_addr, spd, and max_rec.
> >>
> >> This seems possible with a single netdevice for IPv4/6 only if we _always_ use the same fifo address for both IPv4 and IPv6. Do we all agree on that?
> >
> > I do not understand what "that" and "this" mean here.
> > Do you want to have different FIFO on single net_device? If yes, for what?
> >
> 
> Oh, I'm sorry for being mixed-up. I meant that your proposal for 
> enhancing the hardware address seems to be a feasible solution, if we 
> _never_ want to have distinct fifo addresses for IPv4 and IPv6. This 
> will be just impossible with a single netdevice.
> 
> But I have to admit that I have no good use case for different fifo 
> addresses...
> 
> So overall, your proposal seems to be a possible solution. Nevertheless, 
> I can't help that I find it a bit awkward to have speed, max_rec and 
> fifo address in the hardware address of the network device. For me, 
> that's just the GUID.
> 
> I want to have an ack from Stefan Richter before I'm going to implement 
> your solution.

Sorry for my delayed response.

I am not a contributor to net/, hence don't have a say over how the
networking APIs should evolve.

Any solution is fine with me, as long as net/ does not use any definitions
or declarations from <linux/firewire.h>.
-- 
Stefan Richter
-=====-===-= ---= ==-==
http://arcgraph.de/sr/
