From: ivaylo@bglans.net
Subject: problem with r8101 driver
Date: Thu, 29 Jan 2009 12:30:08 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0901291203430.18427@mail.bglans.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bglans.net ([217.79.67.244]:57620 "EHLO mail.bglans.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751302AbZA2K7x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jan 2009 05:59:53 -0500
Received: from mail.bglans.net (mail.bglans.net [217.79.67.244])
	by mail.bglans.net (8.14.2/8.14.2) with ESMTP id n0TAU8qi008392
	for <netdev@vger.kernel.org>; Thu, 29 Jan 2009 12:30:13 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

I've play with r8101 driver and have strange problem.
My envourment is:
Motherboard Intel D945GCLF ( 945GC chipset with integrated CPU Atom 130, 
and Realtek 8102EL, I think it is supported by r8101 driver?)
Linux kernel 2.4.37
gcc 2.95.3
r8101 (all versions, downloaded from www.realtek.com.tw and intel.com)

First of my problems is with compile the driver it seems that there are 4 
structures predefined in r8101_n.c:
netdev_priv - predefined from 
linux-2.4.37/include/linux/netdevice.h
netif_msg_init - predefined from
linux-2.4.37/build/include/linux/netdevice.h
jiffies_to_msecs - predefined from
linux-2.4.36.6/build/include/linux/delay.h
msecs_to_jiffies - predefined from
linux-2.4.36.6/build/include/linux/delay.h

Anyway I try and compile the driver with the original structures from 
kernel and from driver, but the result is the same - I hit the second 
problem.

Second problem is stop transmiting packets after number of tx packets 
reach NUM_TX_DESC defined in r8101.h (1024 is the default value). I play 
with various NUM_TX_DESC the result is the same. If tx packets < 
NUM_TX_DESC lan card work, it transmiting and reciving packets well.

If some body have any ideas or know something about the second problem let 
me know.

Best regards,
Ivaylo Josifov
