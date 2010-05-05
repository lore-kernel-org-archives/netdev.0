From: Abraham Arce <abraham.arce.moreno@gmail.com>
Subject: Re: KS8851: Possible NULL dereferenced in ks8851_rx_pkts
Date: Wed, 5 May 2010 03:41:24 -0500
Message-ID: <x2tcb8016981005050141z8736ebc5ldcf6686694f86762@mail.gmail.com>
References: <z2ocb8016981004080003h7f5ca358r7a1a4106809909ce@mail.gmail.com>
	 <20100413.012844.26960227.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:62134 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932189Ab0EEIlZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 04:41:25 -0400
Received: by mail-fx0-f46.google.com with SMTP id 10so3990480fxm.19
        for <netdev@vger.kernel.org>; Wed, 05 May 2010 01:41:24 -0700 (PDT)
In-Reply-To: <20100413.012844.26960227.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

>> These changes avoid a possible dereference in skb_reserve when skb is
>> NULL. I am increasing rx dropped packet count but not sure about how
>> to handle the dump of frames. Any advice is appreciated.
>
> This isn't sufficient to handle the NULL pointer.
>
> At a minimum you're going to have to do something about
> the fact that the chip has already been told to start
> bringing the packet into the RX fifo.

Ok

>
> If we just return without finishing up the hardware
> operation, the chip is probably going to hang the next
> time we come in here and tell it to start another RX
> DMA operation without having completed the previous one.
>
> The bug definitely needs to be fixed, however, but someone who knows
> this hardware and has access to it for testing will need to implement
> the fix.
>

I'll give a try and test, have a hardware with me...

Thanks!
Abraham
