From: Auke Kok <auke@linux.intel.com>
Subject: Re: packetloss, on e1000e worse than r8169?
Date: Mon, 16 Jun 2008 13:15:41 -0700
Message-ID: <4856C9ED.3070505@linux.intel.com>
References: <20080616193501.M64730@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	e1000-list <e1000-devel@lists.sourceforge.net>
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:55217 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752054AbYFPUR1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jun 2008 16:17:27 -0400
In-Reply-To: <20080616193501.M64730@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko wrote:
> Hi again
> 
> I moved from PCI Realtek 8169 to onboard PCI-Express e1000e, and situation
> become worse. Strange? Yes.
> 
> Here is info
> Load and error rate: 
> 
> MegaRouter-KARAM /sys # ifconfig eth1;sleep 10;ifconfig eth1
> eth1      Link encap:Ethernet  HWaddr 00:19:D1:71:5F:33
>           inet addr:192.168.20.10  Bcast:0.0.0.0  Mask:255.255.255.0
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:91991642 errors:0 dropped:1803444 overruns:0 frame:0
>           TX packets:91914611 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000
>           RX bytes:316112765 (301.4 MiB)  TX bytes:138303107 (131.8 MiB)
>           Memory:90300000-90320000
> 
> eth1      Link encap:Ethernet  HWaddr 00:19:D1:71:5F:33
>           inet addr:192.168.20.10  Bcast:0.0.0.0  Mask:255.255.255.0
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:92812514 errors:0 dropped:1815490 overruns:0 frame:0
>           TX packets:92734865 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000
>           RX bytes:739941322 (705.6 MiB)  TX bytes:560547138 (534.5 MiB)
>           Memory:90300000-90320000
> 
> System load (there is no NAT, no shapers, just routing, around 600-700 routes):
> MegaRouter-KARAM /sys # mpstat 1
> Linux 2.6.26-rc6-git2-build-0029 (MegaRouter-KARAM)     06/16/08
> 
> 22:36:36     CPU   %user   %nice    %sys %iowait    %irq   %soft  %steal  
> %idle    intr/s
> 22:36:37     all    0.00    0.00    0.00    0.00    0.00    1.49    0.00  
> 98.51  19764.00
> 22:36:38     all    0.00    0.00    0.50    0.00    0.00    0.50    0.00  
> 99.01  19888.00
> 22:36:39     all    0.00    0.00    0.00    0.00    0.00    0.50    0.00  
> 99.50  19642.00
> 22:36:40     all    0.00    0.00    0.00    0.00    1.01    9.05    0.00  
> 89.95  19543.00
> 
> (system almost idle)

but has 20000 interrupts per second! that's hardly idle by any account :)

what options did use to load e1000e? can you show the relevant dmesg parts? post
contents of /proc/interrupts?

