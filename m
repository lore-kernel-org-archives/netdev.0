From: Andy Fleming <afleming@gmail.com>
Subject: ICMP echo reply fails
Date: Fri, 26 Mar 2010 16:48:22 -0500
Message-ID: <2acbd3e41003261448q26cb19d4w63487894b24f0254@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:39669 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752413Ab0CZVsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 17:48:24 -0400
Received: by wwe15 with SMTP id 15so6956847wwe.19
        for <netdev@vger.kernel.org>; Fri, 26 Mar 2010 14:48:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For various reasons, we have been running a stress test on one of our
boards.  The test consists of initiating 2-3 flood pings from a
Windows box running Cygwin, plus one additional ping we use as a
"heartbeat".  The ping flood is overwhelming our board (we're dropping
packets at a prodigious rate), but the board continues to respond for
a while.  In addition, we are running a script on the  board which
alternates bringing up and bringing down the interface every ten
seconds.  After a highly variable amount of time, the board stops
replying to the pings.  We suspected a driver issue, however, on
closer inspection, we are still able to send and receive packets (I
can ping *from* the board to the PC, and I can *telnet* from the PC to
the board).  We tried pinging the board from another PC, and it also
failed.  Essentially, ICMP echo requests are being ignored (A glance
at memory indicates that packets are arriving, but no packets are
being enqueued to the ethernet controller).  We still have a lot more
debugging to do, but I was wondering if anyone had ever seen something
like this, or might be quicker to realize the obvious mistake we're
making.

Thanks,
Andy Fleming
