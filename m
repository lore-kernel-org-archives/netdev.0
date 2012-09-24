From: Charles <charles.vejnar@unige.ch>
Subject: ixgbe unstable performance at 1Gb/s
Date: Mon, 24 Sep 2012 17:47:19 +0000 (UTC)
Message-ID: <loom.20120924T193212-646@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:35587 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757188Ab2IXRuB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2012 13:50:01 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1TGCnD-0000xq-GP
	for netdev@vger.kernel.org; Mon, 24 Sep 2012 19:50:03 +0200
Received: from cacheng.unige.ch ([129.194.8.73])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 24 Sep 2012 19:50:03 +0200
Received: from charles.vejnar by cacheng.unige.ch with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 24 Sep 2012 19:50:03 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I hope I am posting on the right mailing-list. If not, sorry; please redirect me
to the right place. Thanks.

I have a new motherboard with integrated Intel X540 10GBase-T. For now, I want
to use it at 1Gb/s.

The bandwidth is only of ~300 Mbit/s (with Iperf). It's actually very unstable
(always varies between 100 to 800 Mbit/s during the transfer).

If I do "ethtool -K eth1 ntuple on", things are a bit better but still very
unstable bandwidth. If I add the kernel parameter "pci=nomsi", everything is
fine (and normal, with the same performance, ~950 MBit/s, as a 1Gbit/s NIC).

I also run the set_irq_affinity.sh script, w/o noticing a difference.

The only weird thing I have found is with ethtoll -S eth1:

    tx_queue_0_packets: 304262
     tx_queue_1_packets: 0
     tx_queue_2_packets: 0
     tx_queue_3_packets: 1
     tx_queue_4_packets: 502939
     tx_queue_5_packets: 677967
     tx_queue_6_packets: 459869
     tx_queue_7_packets: 0
     tx_queue_8_packets: 0
     tx_queue_9_packets: 0
     tx_queue_10_packets: 632626
     tx_queue_11_packets: 1719870
     tx_queue_12_packets: 0
     tx_queue_13_packets: 449811
     tx_queue_14_packets: 0
.......

I am using ArchLinux with kernel 3.5.4. Please ask for more details.

Any help would be appreciated. Thanks

Charles
