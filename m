From: Ang Way Chuang <wcang79@gmail.com>
Subject: TCP throughput drops sharply around MTU of 180 bytes
Date: Sat, 14 Nov 2009 16:48:49 +0800
Message-ID: <51d384e10911140048j46c38559y90349d28e89c6275@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f180.google.com ([209.85.216.180]:36242 "EHLO
	mail-px0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754680AbZKNIsn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Nov 2009 03:48:43 -0500
Received: by pxi10 with SMTP id 10so147387pxi.33
        for <netdev@vger.kernel.org>; Sat, 14 Nov 2009 00:48:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi kernel networking gurus,

     I came across a situation where I need to evaluate the packing
efficiency of small packets. Because TCP is byte oriented protocol,
there is no way
to force it to generate small packets, so I forced it by adjusting MTU.

    However, through the experiment, I found that measured throughput
of TCP stream dropped significantly if MTU is set to value less than 180 bytes.
At first, I thought it must be some bugs on my code. So, I decided to repeat
the test over a dedicated 10Mbps Ethernet link. The results that I measured
over Ethernet is shown below:


MTU                 Throughput (Mbps)
-----                  --------------
181                  4.50
180                  4.39
179                  3.05
178                  3.04

    I used iperf throughout the tests. Can someone enlighten me on this matter?
Why the throughput drops sharply if MTU is less than 180 bytes? Is there some
special meaning associated with 180 that I don't know of?

  Some basic information about my system:
kernel version: 2.6.27.5-117.fc10.x86_64
distro: fedora 10
CPU: Pentium 4 3.00 GHz

   Should you need more information, I shall gladly cooperate. Please keep me
in the loop because it is hard for me to cop with the volume of emails on netdev
mailing list.

    Thank you in advance.

Regards,
Ang Way Chuang
