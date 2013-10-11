From: Kyle Hubert <khubert@gmail.com>
Subject: Peak TCP performance
Date: Thu, 10 Oct 2013 22:34:22 -0400
Message-ID: <CAJoZ4U2eVUd4JiGQ6UFYMdoEwyN=MO8+9S3jGcsaYGN2vqt=3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f182.google.com ([209.85.216.182]:48297 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752194Ab3JKCeX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Oct 2013 22:34:23 -0400
Received: by mail-qc0-f182.google.com with SMTP id n4so2505072qcx.41
        for <netdev@vger.kernel.org>; Thu, 10 Oct 2013 19:34:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm working on a device, I consistently get 27gbps via netperf-2.6.
UDP reports 54gbps.

TCP is maxed out at 100% CPU on the transmit side. On the receive
side, 40% of the CPU. Thus, I didn't believe I could eek anymore
performance out of it.

However, very oddly, if I enabled bridged mode to forward some
packets, TCP performance goes up to 32gbps. The thing that bothers me
is that transmit CPU utilization drops to 65%, and receive CPU
utilization increases to 60%.

What happens when the device becomes bridged to gain so much
performance? Also, can I now take advantage of the extra CPU time
available to drive more traffic? No tunable seems to have any effect..
(except down)

Any ideas?

Cheers,
-Kyle
