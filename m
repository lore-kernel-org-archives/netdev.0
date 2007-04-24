From: "Peter Trifonov" <petert@dcn.infos.ru>
Subject: RE: PROBLEM: sky2 hangs
Date: Tue, 24 Apr 2007 12:24:51 +0400
Message-ID: <20070424082451.25E3C4AC19@dcn.infos.ru>
References: <20070403151908.41E574AC7F@dcn.infos.ru>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "'Stephen Hemminger'" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-9cor.infos.ru ([195.209.229.106]:56715 "EHLO dcn.infos.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1031038AbXDXIY4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Apr 2007 04:24:56 -0400
In-Reply-To: <20070403151908.41E574AC7F@dcn.infos.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Stephen,

Unfortunately the problems with sky2 started again. 

>From time to time NIC stops working. The system log contains the following
messages:
Apr 24 11:50:43 bullet-lin kernel: sky2 eth0: Link is up at 1000 Mbps, full
duplex, flow control both
Apr 24 11:51:55 bullet-lin kernel: sky2 0000:04:00.0: pci hw error (0x2010)
Apr 24 11:53:32 bullet-lin kernel: sky2 eth0: disabling interface
Apr 24 11:53:35 bullet-lin kernel: sky2 eth0: enabling interface
Apr 24 11:53:35 bullet-lin kernel: sky2 eth0: ram buffer 0K
Apr 24 11:53:37 bullet-lin kernel: sky2 eth0: Link is up at 1000 Mbps, full
duplex, flow control both
Apr 24 12:06:32 bullet-lin kernel: sky2 eth0: tx timeout
Apr 24 12:06:32 bullet-lin kernel: sky2 eth0: transmit ring 1 .. 472
report=1 done=1
Apr 24 12:06:32 bullet-lin kernel: sky2 hardware hung? flushing
Apr 24 12:06:32 bullet-lin kernel: sky2 eth0: transmit descriptor error
(hardware problem)
Apr 24 12:06:32 bullet-lin kernel: sky2 eth0: Link is down.
Apr 24 12:06:38 bullet-lin kernel: sky2 eth0: Link is up at 1000 Mbps, full
duplex, flow control both
Apr 24 12:06:38 bullet-lin kernel: sky2 eth0: transmit descriptor error
(hardware problem)
Apr 24 12:06:38 bullet-lin kernel: sky2 eth0: Link is down.
Apr 24 12:06:41 bullet-lin kernel: sky2 eth0: Link is up at 1000 Mbps, full
duplex, flow control both
Apr 24 12:06:41 bullet-lin kernel: sky2 eth0: transmit descriptor error
(hardware problem)
.....

I am running 2.6.20.4 X86-64 kernel

With best regards,
P. Trifonov  

> -----Original Message-----
> From: netdev-owner@vger.kernel.org 
> [mailto:netdev-owner@vger.kernel.org] On Behalf Of Peter Trifonov
> Sent: Tuesday, April 03, 2007 7:19 PM
> To: 'Stephen Hemminger'
> Cc: netdev@vger.kernel.org
> Subject: RE: PROBLEM: sky2 hangs
> 
> Dear Stephen,
> > > I have got a PC based on Gigabyte GA-965P-S3 motherboard with an 
> > > integrated Marvell Yukon 88E8056 PCI-E gigabit ethernet 
> controller.
> > There have been several updates since 2.6.18. Please try 
> and reproduce 
> > with 2.6.20 or later kernel. Or contact the vendor to update their 
> > kernel.
> 
> Thanks a lot!
> 
> After installing 2.6.20 kernel the NIC works perfectly!
> 
> 
> With best regards,
> P. Trifonov  
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe 
> netdev" in the body of a message to majordomo@vger.kernel.org 
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


