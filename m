From: Jon Smirl <jonsmirl@gmail.com>
Subject: Auto generation of IPv6 link local address
Date: Mon, 9 Aug 2010 23:04:26 -0400
Message-ID: <AANLkTik80QZ=KdHGuT99ftx19RcHq2KOUPMR-Lhho5aL@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:40532 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755493Ab0HJDE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Aug 2010 23:04:27 -0400
Received: by wyb32 with SMTP id 32so283022wyb.19
        for <netdev@vger.kernel.org>; Mon, 09 Aug 2010 20:04:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When I bring my Ethernet interface up it automatically gets a link
local IPv6 address.

eth3      Link encap:Ethernet  HWaddr 00:1b:21:59:65:32
          inet addr:192.168.1.8  Bcast:192.168.1.255  Mask:255.255.255.0
          inet6 addr: fe80::21b:21ff:fe59:6532/64 Scope:Link  -->
Missing from my driver
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:1836635 errors:0 dropped:0 overruns:0 frame:0
          TX packets:1283010 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:2259859914 (2.2 GB)  TX bytes:121836850 (121.8 MB)
          Interrupt:16 Memory:dbd60000-dbd80000

I'm writing a device driver for new 802.15.4 hardware. When I bring it
up I don't get an automatic IPv6 link local address. What controls
whether an adapter gets a link local address added or not? My driver
should get one so I must have something wrong in my code.

wpan0     Link encap:IEEE 802.15.4  HWaddr 00:50:c2:ff:fe:a8:a8:c5
          UP BROADCAST RUNNING NOARP  MTU:1280  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:10
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

-- 
Jon Smirl
jonsmirl@gmail.com
