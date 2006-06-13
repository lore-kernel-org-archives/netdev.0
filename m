From: Bharath <bharath.yadav@gmail.com>
Subject: Network Performance Comparison between Linux 2.4 and 2.6
Date: Tue, 13 Jun 2006 16:38:54 +0530
Message-ID: <c4166a920606130408m7780f956i814abb2d3f5aaf78@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:65499 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1750937AbWFMLI4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jun 2006 07:08:56 -0400
Received: by ug-out-1314.google.com with SMTP id e2so2478482ugf
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2006 04:08:55 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi ,

I performed the routing and bridging tests on Linux kernels 2.4.31 and
2.6.16 on a
MIPS(4kc) malta Board , with and without iptables rules.
I observed that the routing performance is quite better( 15-20%
increase) on 2.6 for shorter packet sizes( 64,128 and 256 bytes) and
almost equal to that on 2.4 for larger packet sizes(512, 1024 and 1518
bytes).

The bridging performance follows the same pattern as well.
Is there something I might have missed..? Is this an observed behavior
on 2.6 kernels..?

I have included the throughput figures for bridging for both 2.4 and
2.6 kernels in the table below.
Packet Size(bytes)            2.4.31(Mbps)          2.6.16(Mbps)
------------------------------------------------------------------------------------------
 64                                     2.11                       2.19
128                                    3.59                       3.75
256                                    6.33                       6.48
512                                   10.93                      11.16
1024                                 17.49                      17.33
1280                                 20.00                      19.83
1518                                 22.09                      19.91

About the tests, the MIPS malta board has two D-Link PCI ethernet
cards. A bridge br0 is configured over the two ethernet interfaces (
eth0 and eth1). There is an external traffic generator that is
configured to generate packets of above mentioned sizes and to measure
the throughput correspondingly.

Please let me know if you need any more information.

Thanks,
Bharath
