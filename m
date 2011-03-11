From: Jon Zhou <Jon.Zhou@jdsu.com>
Subject: how to utilize multi tx queue to sent packets
Date: Thu, 10 Mar 2011 22:52:30 -0800
Message-ID: <4A6A2125329CFD4D8CC40C9E8ABCAB9F24FB3D3D62@MILEXCH2.ds.jdsu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og124.obsmtp.com ([64.18.2.26]:59479 "HELO
	exprod7og124.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750905Ab1CKGxh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2011 01:53:37 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi

I am doing some test according to the
website:http://wiki.ipxwarzone.com/index.php5?title=Linux_packet_mmap

use packet_mmap tx_ring to send packet.

I modified the sample code "packetmmap.c" to make it send packets have different outer ip.
so that with the help of RSS, I can achieve higher throughput.

but one thing I saw at the tx side, is that all the packets are sent via the same tx_queue,
which is conflict with what I saw at the rx side.
any idea to make it sent packets via different tx_queues? (spread across the tx_queues)


thanks
jon
