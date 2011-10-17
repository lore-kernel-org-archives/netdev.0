From: Pavel =?utf-8?q?Mat=C4=9Bja?= <pavel@netsafe.cz>
Subject: Re: sky2: only 10Mb/s
Date: Mon, 17 Oct 2011 22:53:39 +0200
Message-ID: <201110172253.39948.pavel@netsafe.cz>
References: <201110171434.50436.pavel@netsafe.cz> <20111017085647.346a37cb@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate1.netsafe.cz ([83.223.49.132]:42143 "EHLO gate1.netsafe.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753990Ab1JQUxn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Oct 2011 16:53:43 -0400
In-Reply-To: <20111017085647.346a37cb@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Hi,
> > I tested new kernel and I have found out I have only 10Mb/s link instead
> > of 100Mb/s to my router.
> > If I did the git bisect right it was caused by commit
> > 4fb99cd6ac4fe6d03a334a6f4ebb2bbfc4b479ed which was submitted by you.
> > 
> > My card is (lspci -v):
> > 05:00.0 Ethernet controller: Marvell Technology Group Ltd. Yukon Optima
> > 88E8059 [PCIe Gigabit Ethernet Controller with AVB] (rev 11)
> > 
> >         Subsystem: ASUSTeK Computer Inc. Device 8439
> >         Flags: bus master, fast devsel, latency 0, IRQ 80
> >         Memory at fe6fc000 (64-bit, non-prefetchable) [size=16K]
> >         I/O ports at b800 [size=256]
> >         Expansion ROM at fe6c0000 [disabled] [size=128K]
> >         Capabilities: [48] Power Management version 3
> >         Capabilities: [5c] MSI: Enable+ Count=1/1 Maskable- 64bit+
> >         Capabilities: [c0] Express Legacy Endpoint, MSI 00
> >         Capabilities: [100] Advanced Error Reporting
> >         Capabilities: [130] Device Serial Number a5-89-6d-ff-ff-30-cf-20
> >         Kernel driver in use: sky2
> > 
> > I'm quite sure it's related to Yukon Optima because "Ethernet controller:
> > Marvell Technology Group Ltd. 88E8056 PCI-E Gigabit Ethernet Controller"
> > in my work computer has 100Mb/s with the same kernel and driver.
> > 
> > I got no response on netdev@vger.kernel.org.
> > Can you help me?
> 
> What is output of dmesg for sky2.
>  dmesg | grep sky2

sky2: driver version 1.28                                                                                                                                                          
sky2 0000:05:00.0: PCI INT A -> GSI 51 (level, low) -> IRQ 51                                                                                                                      
sky2 0000:05:00.0: setting latency timer to 64                                                                                                                                     
sky2 0000:05:00.0: Yukon-2 Optima chip revision 1                                                                                                                                  
sky2 0000:05:00.0: irq 80 for MSI/MSI-X                                                                                                                                            
sky2 0000:05:00.0: eth0: addr 20:cf:30:6d:89:a5                                                                                                                                    
sky2 0000:05:00.0: eth0: enabling interface                                                                                                                                        
sky2 0000:05:00.0: eth0: Link is up at 10 Mbps, full duplex, flow control both                                                                                                     
-- 
Pavel Mateja
