From: Bernd Schubert <bernd-schubert@gmx.de>
Subject: Re: tg3: tg3_stop_block timed out
Date: Wed, 9 Aug 2006 17:20:52 +0200
Message-ID: <200608091720.52599.bernd-schubert@gmx.de>
References: <eb8fmt$6lf$1@sea.gmane.org> <200608080124.38823.bernd-schubert@gmx.de> <1154994410.5328.10.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:35784 "HELO mail.gmx.net")
	by vger.kernel.org with SMTP id S1750982AbWHIPVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 11:21:01 -0400
To: "Michael Chan" <mchan@broadcom.com>
In-Reply-To: <1154994410.5328.10.camel@rh4>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 08 August 2006 01:46, Michael Chan wrote:
> On Tue, 2006-08-08 at 01:24 +0200, Bernd Schubert wrote:
> > tg3.c:v3.49 (Feb 2, 2006)
> > acpi_bus-0201 [01] bus_set_power         : Device is not power manageable
> > eth1: Tigon3 [partno(BCM95704A6) rev 2003 PHY(5704)] (PCIX:100MHz:64-bit)
> > 10/100/1000BaseT Ethernet 00:e0:81:2b:aa:28 eth1: RXcsums[1]
> > LinkChgREG[0] MIirq[0] ASF[1] Split[0] WireSpeed[1] TSOcap[0] eth1:
> > dma_rwctrl[769f4000] dma_mask[64-bit]
> > eth2: Tigon3 [partno(BCM95704A6) rev 2003 PHY(5704)] (PCIX:100MHz:64-bit)
> > 10/100/1000BaseT Ethernet 00:e0:81:2b:aa:29 eth2: RXcsums[1]
> > LinkChgREG[0] MIirq[0] ASF[0] Split[0] WireSpeed[1] TSOcap[1] eth2:
> > dma_rwctrl[769f4000] dma_mask[64-bit]
>
> You have ASF enabled on eth1 but not on eth2 so I wonder if ASF is
> causing the problem.  Can you run the same traffic on eth2 and see if
> you get the same timeout problem?  Thanks.

Currently I have no physical access to the system and eth2 is not connected to 
our switch. I will connect it and run a test as soon as possible (sometime 
this week). However, I don't think I can easily reproduce it even with eth1. 
Its the first time I noticed those error messages in seven months. However, 
we are experiencing random crashes of the system and maybe thats the cause of 
it, who knows. The system is running its root file system over nfs, so a 
network failure will lockup the entire system.

Thanks,
	Bernd
