From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Question: How to configure the Ethernet receive buffer
 allocation (was: (no subject)).
Date: Sat, 13 Oct 2012 10:58:18 +0200
Message-ID: <1350118698.21172.13737.camel@edumazet-glaptop>
References: <CAMJ=MEd89zzLhxt7FYOVCbh5OzW+8jAsx38uV53zCodXvVtfMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ronny Meeus <ronny.meeus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:50249 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751419Ab2JMI6V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Oct 2012 04:58:21 -0400
Received: by mail-ea0-f174.google.com with SMTP id c13so757039eaa.19
        for <netdev@vger.kernel.org>; Sat, 13 Oct 2012 01:58:20 -0700 (PDT)
In-Reply-To: <CAMJ=MEd89zzLhxt7FYOVCbh5OzW+8jAsx38uV53zCodXvVtfMQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-10-13 at 10:39 +0200, Ronny Meeus wrote:
> Hello
> 
> I have an application that needs to handle a massive amount of
> Ethernet packets coming from an FPGA on a dedicated Ethernet link.
> I use a raw Ethernet socket for this. By increasing the receive buffer
> of the socket, I'm able to capture all the packets and process them in
> the application. Since this processing can take some time I have
> increased the receive buffer to 500Mb. The size of the packets is
> 1000bytes so I'm able to capture 500k packets.
> 
> What I observe is that the kernel allocates buffers from the
> slaballoctor for these packets but it takes buffers of 4k while in
> fact the packet is only 1k (This means 2G of kernel memory  is being
> used).
> Is it possible to fine-tune this or is that an alternative for this?
> 
> I already investigated the PACKET_RX_RING solution. This has the
> advantage that the buffers can be 1k but  I do not want to consume
> 500Mb of virtual memory in my application which is running on MIPS in
> 32 bit mode where I only have 2G available in user space.
> 

Need some information 

- Kernel version
- Driver used
- MTU of the link  (default MTU is 1500)
