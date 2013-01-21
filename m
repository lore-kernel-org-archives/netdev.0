From: Stephan Gatzka <stephan.gatzka@gmail.com>
Subject: Re: [RFC:] struct net_device_ops: Add function pointer to fill device
 specific ndisc information
Date: Mon, 21 Jan 2013 20:25:31 +0100
Message-ID: <50FD962B.8020500@gmail.com>
References: <50FC2EE4.3080705@gmail.com> <50FC3BB1.4070005@linux-ipv6.org> <50FC6068.3020302@gmail.com> <50FCA825.7070609@linux-ipv6.org> <50FCDF5D.3060300@gmail.com> <20130121083957.6e2c5a68@stein>
Reply-To: stephan.gatzka@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev <netdev@vger.kernel.org>,
	linux1394-devel@lists.sourceforge.net,
	David Miller <davem@davemloft.net>
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f47.google.com ([209.85.214.47]:44651 "EHLO
	mail-bk0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756388Ab3AUTZf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 14:25:35 -0500
Received: by mail-bk0-f47.google.com with SMTP id jc3so32136bkc.20
        for <netdev@vger.kernel.org>; Mon, 21 Jan 2013 11:25:34 -0800 (PST)
In-Reply-To: <20130121083957.6e2c5a68@stein>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Two net_device instances on one 1394 card would be awkward:  They would
> have to share one instance of isochronous reception context (for reception
> of asynchronous 1394 streams; those are used for broadcasts and
> multicasts).  Such a sharing is surely possible, but if double net_device
> instantiation can be avoided, then avoid it.
>
> Not to mention the user interface problem of having two netifs, one which
> only supports IPv4 and another one which only supports IPv6.  So far I
> never had IPv6 configured into a Linux kernel, but I suppose that folks
> are used to be able to use eth0 etc. for both protocols.

Full ack. And that's the reason why I feel very uncomfortable with a 
Yoshifujis hardware address extensions by fifo_addr, spd, and max_rec.

This seems possible with a single netdevice for IPv4/6 only if we 
_always_ use the same fifo address for both IPv4 and IPv6. Do we all 
agree on that?

Stephan
