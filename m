From: Ajith Adapa <adapa.ajith@gmail.com>
Subject: Re: Regarding bottlenecks for high speed packet generation
Date: Fri, 26 Oct 2012 11:42:28 +0530
Message-ID: <CADAe=+LSeTWTnDk3o46EiLMQqJ6q93yVP_D3J2Ufcfy-_cv6RA@mail.gmail.com>
References: <CADAe=++9KHUx3qX+2==+q0Fq44CJ9tjYcO=HdLYOF3FVuM5Vtg@mail.gmail.com>
 <CAD6jFUScXX0x7yU2f-Cq4B6RZdnQx4dkbADHBL9aYhzQmeKGgA@mail.gmail.com>
 <CADAe=+L2hXpYwH-XyNS2HyHQrMQRCmV_v-bs0Qp+sR-mVkzV4A@mail.gmail.com> <20121025.231814.962022530355865788.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: danborkmann@iogearbox.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:35418 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755033Ab2JZGM7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 02:12:59 -0400
Received: by mail-oa0-f46.google.com with SMTP id h16so2357821oag.19
        for <netdev@vger.kernel.org>; Thu, 25 Oct 2012 23:12:59 -0700 (PDT)
In-Reply-To: <20121025.231814.962022530355865788.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >
> > But does NAPI comes into picture in case of transmission of packets ?
>
> Reclaim of TX descriptors occurs via NAPI.

You mean for every packet sent by the NIC card it drops a interrupt to
reclaim the TX buffers used ?
I am not able to understand why does NIC has to interrupt back instead
of freeing the memory in background.

Might be it does add some bottleneck in my case of transmitting traffic bursts.

Regards,
Ajith
