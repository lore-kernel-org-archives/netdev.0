From: David Miller <davem@davemloft.net>
Subject: Re: Regarding bottlenecks for high speed packet generation
Date: Thu, 25 Oct 2012 23:18:14 -0400 (EDT)
Message-ID: <20121025.231814.962022530355865788.davem@davemloft.net>
References: <CADAe=++9KHUx3qX+2==+q0Fq44CJ9tjYcO=HdLYOF3FVuM5Vtg@mail.gmail.com>
	<CAD6jFUScXX0x7yU2f-Cq4B6RZdnQx4dkbADHBL9aYhzQmeKGgA@mail.gmail.com>
	<CADAe=+L2hXpYwH-XyNS2HyHQrMQRCmV_v-bs0Qp+sR-mVkzV4A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: danborkmann@iogearbox.net, netdev@vger.kernel.org
To: adapa.ajith@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43013 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755671Ab2JZDSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 23:18:15 -0400
In-Reply-To: <CADAe=+L2hXpYwH-XyNS2HyHQrMQRCmV_v-bs0Qp+sR-mVkzV4A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajith Adapa <adapa.ajith@gmail.com>
Date: Fri, 26 Oct 2012 08:19:15 +0530

> Hi,
> 
>> If the driver uses NAPI [1] / the chip supports that, then not. You
>> can observe the hardware / software interrupts via ifpps or watching
>> procfs or some other tools, or simply look at the driver
>> implementation.
>>
>> [1] http://www.linuxfoundation.org/collaborate/workgroups/networking/napi
> 
> But does NAPI comes into picture in case of transmission of packets ?

Reclaim of TX descriptors occurs via NAPI.
