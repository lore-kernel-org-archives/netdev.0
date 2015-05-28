From: sssdrb <sssdrb@gmail.com>
Subject: Problems with receiving packets
Date: Thu, 28 May 2015 10:46:47 +0200
Message-ID: <CA+b3SM+Kzj6RZr7uKHef23NeXDZGf03Ux2eddDLzO8ZE=SJHUQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:34519 "EHLO
	mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753279AbbE1IrT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 04:47:19 -0400
Received: by oifu123 with SMTP id u123so27117142oif.1
        for <netdev@vger.kernel.org>; Thu, 28 May 2015 01:47:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I use Linux kernel 3.3.8 on Arm Xscale based embedded platform.
I noticed that sometimes some applications lost data from network.
To be more detailed - for example I'm using ping command between two
Arm boards. The communication goes through ethernet or wifi. Now from
time to time ping reports that it losts some packets. Additionaly I
run tcpdump on the same side where ping was invoced and it reports
that all the packets arrived (!).

This is the strange part - ping reports lost of data, while tcpdump
shows all of the packets (icmp request and replies).

It seems like there is some problem with transferring network data
from kernel space to user space (in RX path).
I'm sure that all the icmp reply packets are received by ethernet
driver and kernel, but ping application received only part of them
(not all of them).

Is it known problem and is there any solution for it?
