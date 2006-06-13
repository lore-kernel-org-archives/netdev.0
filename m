From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Network Performance Comparison between Linux 2.4 and 2.6
Date: Tue, 13 Jun 2006 09:44:28 -0700
Message-ID: <448EEB6C.6020106@hp.com>
References: <c4166a920606130408m7780f956i814abb2d3f5aaf78@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:53921 "EHLO palrel10.hp.com")
	by vger.kernel.org with ESMTP id S932138AbWFMQo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2006 12:44:29 -0400
To: Bharath <bharath.yadav@gmail.com>
In-Reply-To: <c4166a920606130408m7780f956i814abb2d3f5aaf78@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I have included the throughput figures for bridging for both 2.4 and
> 2.6 kernels in the table below.
> Packet Size(bytes)            2.4.31(Mbps)          2.6.16(Mbps)
> ------------------------------------------------------------------------------------------ 
> 
> 64                                     2.11                       2.19
> 128                                    3.59                       3.75
> 256                                    6.33                       6.48
> 512                                   10.93                      11.16
> 1024                                 17.49                      17.33
> 1280                                 20.00                      19.83
> 1518                                 22.09                      19.91
> 
> About the tests, the MIPS malta board has two D-Link PCI ethernet
> cards. A bridge br0 is configured over the two ethernet interfaces (
> eth0 and eth1). There is an external traffic generator that is
> configured to generate packets of above mentioned sizes and to measure
> the throughput correspondingly.
> 
> Please let me know if you need any more information.

It would be good to include mention of the CPU utilization of the system 
under test, even if it is just to say "the CPU was 100% utilized.

rick jones
http://www.netperf.org/
