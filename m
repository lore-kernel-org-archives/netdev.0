From: alekcejk@googlemail.com
Subject: limited network bandwidth with 3.2.x kernels
Date: Mon, 13 Feb 2012 22:04:52 +0200
Message-ID: <8633039.fHPLx6GNq3@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:44792 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757860Ab2BMUFH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 15:05:07 -0500
Received: by bkcjm19 with SMTP id jm19so4865560bkc.19
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2012 12:05:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I noticed that with 3.2.x kernels download speed from some internet resources
became about half of speed that was with previous kernels (3.1 and older).
I tested Fedora 15 kernels 2.6.41.10 = 3.1.10 and 2.6.42.3 = 3.2.3
(many times rebooted for testing with first and second kernels).
See bug https://bugzilla.redhat.com/show_bug.cgi?id=789659

lsmod:
Module                  Size  Used by
nvidia              10778232  40
i2c_core               28123  1 nvidia
8139too                32490  0
mii                    13311  1 8139too

dmesg:
8139too: 8139too Fast Ethernet driver 0.9.28
8139too 0000:01:02.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
8139too 0000:01:02.0: eth0: RealTek RTL8139 at , IRQ 22
8139too 0000:01:02.0: eth0: link up, 100Mbps, full-duplex, lpa 0x41E1

For testing I selected fastest for me download mirrors of FreeBSD and Ubuntu,
also I tested download speed from site speedtest.tele2.net.

For these sites download speed with 3.1 kernels (and older) is about 11 MB/s
but with 3.2.x kernels - limited 5.5 MB/s and for some sites still approximately
the same as with 3.1 kernels (see bug mentioned above).

Also I want to pay attention that limited speed stays constant - always
5.5 MB/s with straight line on traffic plotter as if was network bandwidth shaping.
With 3.1 kernels this never happens - speed can vary in some ranges
but at maximum it is about 11 MB/s, no limitations such as 5.5 MB/s.

-- 
Alexey Kurov <nucleo@fedoraproject.org>
