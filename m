From: "juice" <juice@swagman.org>
Subject: Re: Hight speed data sending from custom IP out of kernel
Date: Tue, 19 Apr 2011 14:34:03 +0300
Message-ID: <53f539ea861e1a24bde4aadceff0b3bb.squirrel@www.liukuma.net>
Reply-To: juice@swagman.org
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: monstr@monstr.eu, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.liukuma.net ([62.220.235.15]:19515 "EHLO www.liukuma.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752325Ab1DSLoR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2011 07:44:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michal.

How fast do you need to send the data?
I have an application where I send test stream out to GE line and can fill
the total capacity of the ethernet regardless of the packet size.

The test stream I am sending is stored in kernel memory, and therefore is
limited by the amount of free memory. 200M is no problem.

The solution I am using is loosely based on the pktgen module, except that
my module can load a wireshark capture from userland program and then send
it from ethernet interface in wire speed.

  - Juice -


> Hi,
> I would like to create demo for high speed data sending from custom IP
through
> the ethernet. I think the best description is that there are dmaable memory
> mapped registers or just memory which store data I want to send (for
example 200MB).
> Linux should handle all communication between target(probably server)
and
> host
> (client) but data in the packets should go from that custom IP and can't go
> through the kernel because of performance issue.
> Ethernet core have own DMA which I could use but the question is if
there
> is any
> option how to convince the kernel that data will go directly from memory
mapped
> registers and the kernel/driver/... just setup dma BD for headers and
second for
> data.
> Do you have any experience with any solution with passing data
completely
> out of
> kernel?
> Thanks,
> Michal
> --
> Michal Simek, Ing. (M.Eng)
> w: www.monstr.eu p: +42-0-721842854
> Maintainer of Linux kernel 2.6 Microblaze Linux -
> http://www.monstr.eu/fdt/
> Microblaze U-BOOT custodian
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in the
body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html




