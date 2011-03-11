From: zhou rui <zhourui.cn@gmail.com>
Subject: how to utilize multi tx queue to sent packets?
Date: Fri, 11 Mar 2011 09:44:08 +0800
Message-ID: <AANLkTimscFFZ2umPHpYS4ETgNt7GjgAQbYwRzEGps4ww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:46176 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755044Ab1CKBoJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2011 20:44:09 -0500
Received: by vxi39 with SMTP id 39so2157619vxi.19
        for <netdev@vger.kernel.org>; Thu, 10 Mar 2011 17:44:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi

I am doing some test according to the
website:http://wiki.ipxwarzone.com/index.php5?title=Linux_packet_mmap

use packet_mmap tx_ring to send packet.

I modified the sample code "packetmmap.c" to make it send packets have
different outer ip.
so that with the help of RSS, I can achieve higher throughput.

but one thing I saw at the tx side, is that all the packets are sent
via the same tx_queue,which is conflict with what I saw at the rx
side.
any idea to make it sent packets via different tx_queues? (spread
across the tx_queues)


thanks
jon
