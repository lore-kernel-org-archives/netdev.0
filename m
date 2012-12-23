From: Stephan Gatzka <stephan.gatzka@gmail.com>
Subject: Re: IPv6 over Firewire
Date: Sun, 23 Dec 2012 19:25:05 +0100
Message-ID: <50D74C81.1000400@gmail.com>
References: <50D49659.1000101@gmail.com> <50D4A219.7080807@linux-ipv6.org> <50D4ACFA.6040901@gmail.com> <50D4BD2F.7060006@linux-ipv6.org> <50D54ED9.6090908@gmail.com> <50D6BF6F.2030207@linux-ipv6.org> <50D6E73F.70301@gmail.com> <50D6F488.7060308@linux-ipv6.org> <50D7062D.8040901@gmail.com> <50D73ABB.4020800@linux-ipv6.org>
Reply-To: stephan.gatzka@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
	stefanr@s5r6.in-berlin.de
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:39810 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751599Ab2LWSZK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Dec 2012 13:25:10 -0500
Received: by mail-bk0-f46.google.com with SMTP id q16so3134546bkw.33
        for <netdev@vger.kernel.org>; Sun, 23 Dec 2012 10:25:08 -0800 (PST)
In-Reply-To: <50D73ABB.4020800@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Please, please do not alter bits in your driver, to maintain
> extensibility of protocols.
>
> I am definitely okay to have firewire supporting stuff in
> net/ipv6/ndisc.c.  Since we already have notification
> mechanism, I don't think it will be large.
>
O.k., let's try it your way.

I believe the the changes in the transmit portions for ndisc are rather 
simple. All firewire specific information is stored in the private data 
of struct net_device. For the receive section I think I have to change 
something in ndisc_recv_ns(), I'll figure that out. Maybe I need some 
(small) support from you, but I think we can do that off list.

I'll try it out but after Christmas. :)

But I have to emphasize that I really need (read) access to the firewire 
specific portions of the link layer option in the firewire net driver. 
That _is_ necessary to build the relation between the firewire hardware 
address (GUID) and the corresponding firewire node.

Because you mentioned IPSEC: Are the ndisc packets also encrypted? If 
so, I just can't imagine how I can do the mapping of firewire hardware 
addresses and firewire nodes.

@Stefan: Are you o.k. if I go that way?

Regards,

Stephan
