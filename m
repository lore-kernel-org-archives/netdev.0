From: =?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>
Subject: results with diff affinity settings using ixgbe
Date: Tue, 27 Jan 2009 16:14:22 +0100
Message-ID: <497F24CE.6060201@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:39007 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754928AbZA0POZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2009 10:14:25 -0500
Received: from unknown (HELO [192.168.1.10]) (itcare_pstaszewski@[83.7.203.157])
          (envelope-sender <pstaszewski@itcare.pl>)
          by smtp.iq.pl with AES256-SHA encrypted SMTP
          for <netdev@vger.kernel.org>; 27 Jan 2009 15:14:22 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I make some tests with affinity on my machine with some traffic load.
If someone want look:



Traffic in all test was 350Mbit/s TX and the same on RX

RX queues on cpu6 / TX queues on cpu7 / intel e1000e on cpu4
Average:     CPU   %user   %nice    %sys %iowait    %irq   %soft  
%steal   %idle    intr/s
Average:     all    0.05    0.00    0.00    0.00    1.89   10.03    
0.00   88.03 221511.70
Average:       0    0.40    0.00    0.00    0.00    0.00    0.00    
0.00   99.60      0.70
Average:       1    0.00    0.00    0.00    0.00    0.00    0.00    
0.00  100.00      0.80
Average:       2    0.00    0.00    0.00    0.00    0.00    0.00    
0.00  100.00      0.70
Average:       3    0.00    0.00    0.10    0.00    0.00    0.40    
0.00   99.50      0.70
Average:       4    0.00    0.00    0.00    0.00    2.06   18.74    
0.00   79.20  12870.50
Average:       5    0.00    0.00    0.00    0.00    0.00    0.00    
0.00  100.00      1.30
Average:       6    0.00    0.00    0.00    0.00    2.65   57.49    
0.00   39.86  59410.60
Average:       7    0.00    0.00    0.00    0.00   10.50    5.00    
0.00   84.50  53977.90


RX queues on cpu6 / TX queues on cpu7 / intel e1000e on cpu1
Average:     CPU   %user   %nice    %sys %iowait    %irq   %soft  
%steal   %idle    intr/s
Average:     all    0.08    0.00    0.09    0.00    0.75   14.24    
0.00   84.84 215755.20
Average:       0    0.50    0.00    0.00    0.00    0.00    0.00    
0.00   99.50      1.30
Average:       1    0.00    0.00    0.53    0.00    2.34   36.91    
0.00   60.21   9771.90
Average:       2    0.00    0.00    0.00    0.00    0.00    0.00    
0.00  100.00      1.40
Average:       3    0.00    0.00    0.00    0.00    0.00    0.20    
0.00   99.80      1.30
Average:       4    0.00    0.00    0.00    0.00    0.00    0.00    
0.00  100.00      1.30
Average:       5    0.00    0.00    0.00    0.00    0.00    0.00    
0.00  100.00      1.80
Average:       6    0.00    0.00    0.20    0.00    2.65   78.51    
0.00   18.64  54691.70
Average:       7    0.00    0.00    0.00    0.00    1.03    0.51    
0.00   98.46  54060.60


All RX/TX queues from ixgbe on one cpu7 / intel e1000e on cpu1
Average:     CPU   %user   %nice    %sys %iowait    %irq   %soft  
%steal   %idle    intr/s
Average:     all    0.07    0.00    0.10    0.00    1.19    9.44    
0.00   89.19 210155.50
Average:       0    0.60    0.00    0.00    0.00    0.00    0.00    
0.00   99.40      0.60
Average:       1    0.00    0.00    0.41    0.00    2.87   16.27    
0.00   80.45  13045.30
Average:       2    0.00    0.00    0.00    0.00    0.00    0.00    
0.00  100.00      0.70
Average:       3    0.10    0.00    0.30    0.00    0.00    0.20    
0.00   99.40      0.60
Average:       4    0.00    0.00    0.00    0.00    0.00    0.00    
0.00  100.00      0.70
Average:       5    0.00    0.00    0.00    0.00    0.00    0.00    
0.00  100.00      1.10
Average:       6    0.00    0.00    0.00    0.00    0.00    0.00    
0.00  100.00      0.60
Average:       7    0.00    0.00    0.10    0.00    6.77   60.00    
0.00   33.13 107242.50


All RX/TX queues from ixgbe on one cpu7 / intel e1000e on cpu4
Average:     CPU   %user   %nice    %sys %iowait    %irq   %soft  
%steal   %idle    intr/s
Average:     all    0.05    0.00    0.04    0.00    1.24    9.55    
0.00   89.12 212186.90
Average:       0    0.40    0.00    0.00    0.00    0.00    0.00    
0.00   99.60      2.20
Average:       1    0.10    0.00    0.00    0.00    0.00    0.00    
0.00   99.90      2.30
Average:       2    0.00    0.00    0.00    0.00    0.00    0.00    
0.00  100.00      2.20
Average:       3    0.00    0.00    0.00    0.00    0.00    0.30    
0.00   99.70      2.20
Average:       4    0.00    0.00    0.00    0.00    1.03   14.68    
0.00   84.28  11965.50
Average:       5    0.00    0.00    0.10    0.00    0.00    0.00    
0.00   99.90      2.80
Average:       6    0.00    0.00    0.00    0.00    0.00    0.00    
0.00  100.00      2.30
Average:       7    0.00    0.00    0.20    0.00    8.97   62.69    
0.00   28.13 110943.50


Affinity set to "ffffffff" / and intel e1000e is on cpu4
Average:     CPU   %user   %nice    %sys %iowait    %irq   %soft  
%steal   %idle    intr/s
Average:     all    0.10    0.00    0.14    0.01    1.16   15.07    
0.00   83.52 185043.10
Average:       0    0.00    0.00    0.00    0.10    2.90   36.90    
0.00   60.10   9008.60
Average:       1    0.00    0.00    0.10    0.00    2.30   28.36    
0.00   69.24   9009.10
Average:       2    0.80    0.00    0.40    0.00    0.50   13.76    
0.00   84.54   9008.90
Average:       3    0.00    0.00    0.20    0.00    0.20    4.61    
0.00   94.98   9008.90
Average:       4    0.00    0.00    0.10    0.00    2.35   19.55    
0.00   77.99  14142.10
Average:       5    0.00    0.00    0.10    0.00    0.20    3.85    
0.00   95.84   9009.10
Average:       6    0.00    0.00    0.10    0.00    0.40    4.22    
0.00   95.28   9008.90
Average:       7    0.00    0.00    0.10    0.00    0.51    8.69    
0.00   90.70   9009.00

And if i split more RX/TX queues to different CPU-s i have more load 
done by:
CPU: Core 2, speed 2999.98 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a 
unit mask of 0x00 (Unhalted core cycles) count 100000
samples  %        image name               app name                 
symbol name
458001   29.5565  vmlinux                  vmlinux                  
native_read_tsc

If all interrupts are on one CPU i have the best results
So for me the best is to put ixgbe work on one CPU or make affinity to 
balance over all cpus

But something is wrong with my intel e1000e
because if i put intel e1000e with ixgbe on the same CPU system have 
100% cpu load and all hangs.



