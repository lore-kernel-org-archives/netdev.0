From: David Miller <davem@davemloft.net>
Subject: Re: i386 vs x86_64 struct tpacket_hdr layout
Date: Fri, 20 Dec 2013 13:38:54 -0500 (EST)
Message-ID: <20131220.133854.672157982782686878.davem@davemloft.net>
References: <52B4465E.2090904@aimvalley.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org
To: nvbolhuis@aimvalley.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41811 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750817Ab3LTSi4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 13:38:56 -0500
In-Reply-To: <52B4465E.2090904@aimvalley.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Norbert van Bolhuis <nvbolhuis@aimvalley.nl>
Date: Fri, 20 Dec 2013 14:30:06 +0100

> 
> I'm compiling my 32bit application with -m32 on a x86_64
> system/kernel.
> 
> Things aren't working because for my application tp_len is at offset 4
> but for the kernel it is at offset 8.
> 
> struct tpacket_hdr {
>         unsigned long   tp_status;
>         unsigned int    tp_len;
>         unsigned int    tp_snaplen;
>         unsigned short  tp_mac;
>         unsigned short  tp_net;
>         unsigned int    tp_sec;
>         unsigned int    tp_usec;
> };
> 
> How is this suppose to work ?

This is why you should use tpacket layout v2 or v3, rather than v1,
they fix these issues.
