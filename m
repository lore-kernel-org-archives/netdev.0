From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3: tg3_stop_block timed out
Date: Mon, 07 Aug 2006 16:46:50 -0700
Message-ID: <1154994410.5328.10.camel@rh4>
References: <eb8fmt$6lf$1@sea.gmane.org> <1154992063.5328.3.camel@rh4>
 <200608080124.38823.bernd-schubert@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:55046 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S932366AbWHGXpx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 19:45:53 -0400
To: "Bernd Schubert" <bernd-schubert@gmx.de>
In-Reply-To: <200608080124.38823.bernd-schubert@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-08 at 01:24 +0200, Bernd Schubert wrote:

> 
> tg3.c:v3.49 (Feb 2, 2006)
> acpi_bus-0201 [01] bus_set_power         : Device is not power manageable
> eth1: Tigon3 [partno(BCM95704A6) rev 2003 PHY(5704)] (PCIX:100MHz:64-bit) 10/100/1000BaseT Ethernet 00:e0:81:2b:aa:28
> eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[1] Split[0] WireSpeed[1] TSOcap[0]
> eth1: dma_rwctrl[769f4000] dma_mask[64-bit]
> eth2: Tigon3 [partno(BCM95704A6) rev 2003 PHY(5704)] (PCIX:100MHz:64-bit) 10/100/1000BaseT Ethernet 00:e0:81:2b:aa:29
> eth2: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] Split[0] WireSpeed[1] TSOcap[1]
> eth2: dma_rwctrl[769f4000] dma_mask[64-bit]
> 

You have ASF enabled on eth1 but not on eth2 so I wonder if ASF is
causing the problem.  Can you run the same traffic on eth2 and see if
you get the same timeout problem?  Thanks.

