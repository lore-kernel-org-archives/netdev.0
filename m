From: Shan Wei <shanwei88@gmail.com>
Subject: Re: Specific question about packet dropping
Date: Wed, 28 Nov 2012 19:45:29 +0800
Message-ID: <50B5F959.5080000@gmail.com>
References: <CALZVapnQrH9YvCOh8OnGFs1V28nPfX4p=GK=M0VnqHjZCU8=1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Javier Domingo <javierdo1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:40180 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754358Ab2K1Lpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 06:45:39 -0500
Received: by mail-pa0-f46.google.com with SMTP id bh2so6720518pad.19
        for <netdev@vger.kernel.org>; Wed, 28 Nov 2012 03:45:39 -0800 (PST)
In-Reply-To: <CALZVapnQrH9YvCOh8OnGFs1V28nPfX4p=GK=M0VnqHjZCU8=1Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Javier Domingo said, at 2012/11/28 18:40:
> Hi,
> 
> Where are packets dropped?
> 
> I reading code I think just found:
> - In the NIC
> - In the netif_receive_skb
> 
> Is there any other place I can have missed?

There is many reasons, following is not whole.

For receiver:
1. NIC
2. __netif_receive_skb(unknown packet type)
3. ip_rcv(abnormal packet, route reason...)
4. tcp/udp (unknown port, receive buff limit..)

For Sender:
1. tcp/udp(send buffer limit)
2. ip(route reason....)
3. arp(resolved_discards)
4. qdisc(queue limit)


Best Regards
Shan Wei

> 
> Javier Domingo
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
