From: Markus Brunner <systemprogrammierung.brunner@gmail.com>
Subject: Re: [PATCH 0/3] drivers: net: cpsw: phy-handle fixes
Date: Thu, 24 Dec 2015 10:10:28 +0100
Message-ID: <15436621.qYLgeqbLMk@localhost>
References: <1450830994-5450-1-git-send-email-drivshin.allworx@gmail.com> <CABr+WTm=Oo16=qB6dyO6ZhUUz0307ROi=o270Rac2R4W5-usjg@mail.gmail.com> <20151223201816.1a4bd0f6.drivshin.allworx@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Nicolas Chauvet <kwizart@gmail.com>, netdev@vger.kernel.org,
	devicetree@vger.kernel.org,
	Daniel Trautmann <dtrautmann@ibhsoftec-sps.de>,
	linux-omap@vger.kernel.org, Mugunthan V N <mugunthanvnm@ti.com>,
	Pascal Speck <kernel@iktek.de>, Heiko Schocher <hs@denx.de>,
	David Miller <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33041 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753645AbbLXJM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2015 04:12:29 -0500
In-Reply-To: <20151223201816.1a4bd0f6.drivshin.allworx@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 23 December 2015 20:18:16 David Rivshin wrote:
> On Thu, 24 Dec 2015 00:34:49 +0100
> 
> Nicolas Chauvet <kwizart@gmail.com> wrote:
> > 2015-12-23 22:54 GMT+01:00 David Rivshin (Allworx) <
> > 
> > here is the full dmesg output with this serie applied to linux-next:
> > http://ur1.ca/ocvs6
Linux version 4.4.0-rc6-next-20151223-00029-g858e234 (kwizart@nchauvet-
desktop) (gcc version 5.2.1 20150716 (Red Hat Cross 5.2.1-3) (GCC) ) #15 SMP 
Wed Dec 23 18:29:57 CET 2015

I will refer to this as 0029

> > Comparing a dmesg output where the driver work: it doesn't show any
> > difference from the quoted lines:
> > http://paste.fedoraproject.org/304248/45086839/
Linux version 4.4.0-rc6-next-20151223-00023-g71d15d9 (kwizart@nchauvet-
desktop) (gcc version 5.2.1 20150716 (Red Hat Cross 5.2.1-3) (GCC) ) #12 SMP 
Wed Dec 23 10:36:46 CET 2015

I will refer to this as 0023

I made a "grep fail" on both dmesg and 0023 seems to lack edma, mmc and usb. I 
wonder how ethernet could have worked. There seems also to be a problem with 
the clocks.

fails that are specific to 0023:

ti_dt_clocks_register: failed to lookup clock node sysclk5_ck
ti_dt_clocks_register: failed to lookup clock node sysclk8_ck
platform 47400000.usb: clk_get for pll260dcoclkldo failed
platform 48060000.mmc: clk_get for sysclk8_ck failed
platform 481d8000.mmc: clk_get for sysclk8_ck failed
platform 47810000.mmc: clk_get for sysclk8_ck failed
edma 49000000.edma: pm_runtime_get_sync() failed
edma: probe of 49000000.edma failed with error -22
musb-dsps: probe of 47401400.usb failed with error -16
musb-dsps: probe of 47401c00.usb failed with error -16
cppi41-dma-engine: probe of 47400000.dma-controller failed with error -16
omap_hsmmc: probe of 48060000.mmc failed with error -2
omap_hsmmc: probe of 481d8000.mmc failed with error -2
omap_hsmmc: probe of 47810000.mmc failed with error -2
