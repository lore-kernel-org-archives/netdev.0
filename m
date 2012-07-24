From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [BUG] tg3: frequent freezes
Date: Mon, 23 Jul 2012 17:13:52 -0700
Message-ID: <1343088832.5240.11.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1342503329.2626.30.camel@edumazet-glaptop>
 <1342508189.2168.14.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1841 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752824Ab2GXAP0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jul 2012 20:15:26 -0400
In-Reply-To: <1342508189.2168.14.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-16 at 23:56 -0700, Michael Chan wrote: 
> On Tue, 2012-07-17 at 07:35 +0200, Eric Dumazet wrote:
> > [  266.248330] tg3 0000:09:00.0: eth0: 0x00004800: 0x080303fe,
> > 0x00000010, 0x00000000, 0x00000020
> 
> RDMAC_STATUS (0x4804) is showing 0x10 which is parity error.
> 
> >[  266.247878] tg3 0000:09:00.0: eth0: 0x00000000: 0x167314e4,
> >0x40100506, 0x02000002, 0x00000010
> 
> PCI Status (0x06) is also showing SERR (0x4000)
> 
> Assuming your chip is not a bad chip, I'll have to look around for a
> 5755M and see if I can duplicate the problem.

Hi Eric, I found the same 5755m NIC as yours but I couldn't duplicate
any problems.  I ran netperf in a loop and it was running fine.

Here's my device and it should be identical to yours:

tg3.c:v3.123 (March 21, 2012)
tg3 0000:20:00.0: eth0: Tigon3 [partno(BCM95755m) rev a002] (PCI Express) MAC address 00:10:18:00:00:00
tg3 0000:20:00.0: eth0: attached PHY is 5755 (10/100/1000Base-T Ethernet) (WireSpeed[1], EEE[0])
tg3 0000:20:00.0: eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
tg3 0000:20:00.0: eth0: dma_rwctrl[76180000] dma_mask[64-bit]
