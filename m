From: Todd Bezenek <bezenek@gmail.com>
Subject: Cause of Large Latency Difference Between 1179-byte and 1180-byte UDP Frames?
Date: Wed, 20 May 2015 21:50:04 -0700
Message-ID: <CAE1W6VpPJwKtFGmeLuStt-A8JjGj2xU8RitonBHBs3dH9pXYRA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:34086 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750815AbbEUEuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 00:50:05 -0400
Received: by igbhj9 with SMTP id hj9so1113984igb.1
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 21:50:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm pushing 10,000 frames per second of UDP traffic through a Linux
system with a bridge configured between two 1GbE ports.

Iptables is installed and running, but the default rule is ACCEPT with
no other rules.

When I make the packets 1179 bytes in size (total size includes
Ethernet header, etc.), I see the latency of most packets between 60
and 200 usec.  When I change the size to 1180 bytes, I start seeing
about 1% of the packets with latencies larger than 300 usec, and some
as high as 500+ usec.

Any ideas what buffer size, cache line count, TLB reach, etc. might be
causing this dramatic change?

Cut-and-paste to my terminal is not working, so limited info here:

Kernel:  3.12.20 x86-64
Processor:  Intel E3845 (Atom, 4 cores)
Network interface driver:  Intel igb

Thank you for any helpful pointers.

-Todd

-- 
Todd Bezenek
bezenek@gmail.com

A people hire A people, B people hire C people.
  --Jim Gray
