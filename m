From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3 does not want to go up (config space problems).
Date: Mon, 14 May 2007 10:15:23 -0700
Message-ID: <1179162923.25622.22.camel@dell>
References: <20070514145419.GA19679@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev" <netdev@vger.kernel.org>
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4985 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754519AbXENQ1S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 May 2007 12:27:18 -0400
In-Reply-To: <20070514145419.GA19679@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-05-14 at 18:54 +0400, Evgeniy Polyakov wrote:

> I've cought a problem with my laptop and tg3 driver.
> Suddenly (it was turned off quite for a while) tg3 driver does not start
> up.
> 
> Here is dmesg messages (copied by hand, some bits are ommitted):
> acpi: ... // device enbaled in couple of words
> 
> eth0: Tigon3 [partno(BMC5705mA3) rev 3003 PHY(5705)] pci:33/32, 10/100
> 
> eth0: rxcsum[1] linkchgreg[0] miirq[0] asf[0] split[0] wirespeed[0]
> tsocap[1]
> eth0: dma_rwctrl[763f0000] dma_mask[64 bit]
> 
> PM: writing back config space on device /* tg3 device pcix id*/ at
> offset b (was 165d14e4, writing 890103c)
> offset 3 (was 0, writing 4010)
> offset 2 (was 2000000, writing 2000003)
> offset 1 (was 2b00000, writing 2b00006)
> offset 0 (was 165d14e4, writing 165e14e4)

These messages are harmless.  The way the driver saves and restores the
pci state cause these benign messages to appear.

> 
> ADDRCONF(NETDEV_UP): eth0 link is not ready
> 
> This problem never happend before, but suddenly appeared after quite
> long suspend to disk (several month I think).
> Nothing was changed in hardware.
> Both 2.6.18 and 2.6.21-rc3 have the same issue.
> No interrupts reported in /proc/interrupts.

I'll look into this.  Thanks.

> 
> I have 2.6.21-rc3 source tree in laptop, so can apply patches by hand
> reading them from main desktop, but can not (easily) install additional 
> software.
> 
> Thanks.
> 

