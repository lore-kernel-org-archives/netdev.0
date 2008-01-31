From: David Acker <dacker@roinet.com>
Subject: Re: e1000 full-duplex TCP performance well below wire speed
Date: Thu, 31 Jan 2008 09:50:14 -0500
Message-ID: <47A1E026.2070805@roinet.com>
References: <Pine.LNX.4.63.0801300324000.6391@trinity.phys.uwm.edu>	<20080130.055333.192844925.davem@davemloft.net>	<Pine.LNX.4.63.0801300758020.11487@trinity.phys.uwm.edu>	<20080130082136.1017631d@deepthought>	<Pine.LNX.4.63.0801301610240.19938@trinity.phys.uwm.edu>	<649aecc70801301617m6331bcb8i8ce60366e182c739@mail.gmail.com> <20080131064533.ef0ae932.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: SANGTAE HA <sangtae.ha@gmail.com>,
	Bruce Allen <ballen@gravity.phys.uwm.edu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Bill Fink <billfink@mindspring.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759136AbYAaOz6@vger.kernel.org>
In-Reply-To: <20080131064533.ef0ae932.billfink@mindspring.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bill Fink wrote:
> If the receive direction uses a different GigE NIC that's part of the
> same quad-GigE, all is fine:
> 
> [bill@chance4 ~]$ nuttcp -f-beta -Itx -w2m 192.168.6.79 & nuttcp -f-beta -Irx -r -w2m 192.168.5.79
> tx:  1186.5051 MB /  10.05 sec =  990.2250 Mbps 12 %TX 13 %RX 0 retrans
> rx:  1186.7656 MB /  10.05 sec =  990.5204 Mbps 15 %TX 14 %RX 0 retrans
Could this be an issue with pause frames?  At a previous job I remember 
having issues with a similar configuration using two broadcom sb1250 3 
gigE port devices. If I ran bidirectional tests on a single pair of 
ports connected via cross over, it was slower than when I gave each 
direction its own pair of ports.  The problem turned out to be that 
pause frame generation and handling was not configured correctly.
-Ack
