From: Eli Cohen <eli@mellanox.co.il>
Subject: receive errors
Date: Tue, 03 Jul 2007 18:39:20 +0300
Message-ID: <1183477160.25031.170.camel@mtls03>
Reply-To: eli@mellanox.co.il
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: linux-net@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from p02c11o142.mxlogic.net ([208.65.144.75]:53666 "EHLO
	p02c11o142.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755233AbXGCQmP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2007 12:42:15 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I am running a benchmark that uses a UDP socket to send small packets
(20 bytes) from on side to the other side. I experience packet loss
reported by the benchmark and I can see that it matches what I see with
netstat:

[root@sw174 opt]# netstat -us
Udp:
    26971289 packets received
    7 packets to unknown port received.
    32615 packet receive errors
    155761284 packets sent

Can someone please direct to the source code that detects such receive
errors and/or suggest why such a thing could happen?

Thanks
Eli

