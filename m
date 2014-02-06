From: Daniel J Blueman <daniel@quora.org>
Subject: AX88179_178A USB3 ethernet adapter performance issue
Date: Thu, 6 Feb 2014 22:33:26 +0800
Message-ID: <CAMVG2ssoBwk56n-k5VB9yO2LP4wc+gTv4o_17r-WYakwE6h2uQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Netdev <netdev@vger.kernel.org>
To: Freddy Xin <freddy@asix.com.tw>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f45.google.com ([209.85.219.45]:51174 "EHLO
	mail-oa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305AbaBFOd1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 09:33:27 -0500
Received: by mail-oa0-f45.google.com with SMTP id i11so2392856oag.18
        for <netdev@vger.kernel.org>; Thu, 06 Feb 2014 06:33:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Freddy et al,

I'm experiencing poor network performance using an ASIX AX88179_178A
USB3 to ethernet adapter using any recent linux kernel (eg 3.11),
using an Intel XHCI USB3 controller.

Running iperf tests between one host with a gigabit PCIe NIC, via a
gigabit switch to the other host with various interfaces:

PCIe bcm957762: send 818Mb/s, recv 910Mb/s
USB2 smsc75xx: send 341Mb/s, recv 330Mb/s
USB3 ax88179_178a: send 347Mb/s, recv 18.7Mb/s

Are you able to reproduce the same 19Mb/s receive rate there?

Many thanks,
  Daniel
-- 
Daniel J Blueman
