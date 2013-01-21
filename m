From: Stephan Gatzka <stephan.gatzka@gmail.com>
Subject: Re: [RFC:] struct net_device_ops: Add function pointer to fill device
 specific ndisc information
Date: Mon, 21 Jan 2013 22:16:41 +0100
Message-ID: <50FDB039.2070604@gmail.com>
References: <50FC2EE4.3080705@gmail.com> <50FC3BB1.4070005@linux-ipv6.org> <50FC6068.3020302@gmail.com> <50FCA825.7070609@linux-ipv6.org> <50FCDF5D.3060300@gmail.com> <20130121083957.6e2c5a68@stein> <50FD962B.8020500@gmail.com> <50FD9DB7.60802@linux-ipv6.org>
Reply-To: stephan.gatzka@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stefan Richter <stefanr@s5r6.in-berlin.de>,
	netdev <netdev@vger.kernel.org>,
	linux1394-devel@lists.sourceforge.net,
	David Miller <davem@davemloft.net>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f47.google.com ([209.85.214.47]:36439 "EHLO
	mail-bk0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750713Ab3AUVQp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 16:16:45 -0500
Received: by mail-bk0-f47.google.com with SMTP id jc3so92238bkc.34
        for <netdev@vger.kernel.org>; Mon, 21 Jan 2013 13:16:44 -0800 (PST)
In-Reply-To: <50FD9DB7.60802@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>> Full ack. And that's the reason why I feel very uncomfortable with a Yoshifujis hardware address extensions by fifo_addr, spd, and max_rec.
>>
>> This seems possible with a single netdevice for IPv4/6 only if we _always_ use the same fifo address for both IPv4 and IPv6. Do we all agree on that?
>
> I do not understand what "that" and "this" mean here.
> Do you want to have different FIFO on single net_device? If yes, for what?
>

Oh, I'm sorry for being mixed-up. I meant that your proposal for 
enhancing the hardware address seems to be a feasible solution, if we 
_never_ want to have distinct fifo addresses for IPv4 and IPv6. This 
will be just impossible with a single netdevice.

But I have to admit that I have no good use case for different fifo 
addresses...

So overall, your proposal seems to be a possible solution. Nevertheless, 
I can't help that I find it a bit awkward to have speed, max_rec and 
fifo address in the hardware address of the network device. For me, 
that's just the GUID.

I want to have an ack from Stefan Richter before I'm going to implement 
your solution.

Regards,

Stephan
