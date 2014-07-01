From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: [PATCH CFT 00/30] Initial round of Freescale FEC ethernet patches
Date: Tue, 1 Jul 2014 03:23:27 +0000
Message-ID: <f570bad3b6954703b930e6b9a516f372@BLUPR03MB373.namprd03.prod.outlook.com>
References: <20140627151542.GL32514@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2lp0242.outbound.protection.outlook.com ([207.46.163.242]:42249
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752635AbaGADXa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 23:23:30 -0400
In-Reply-To: <20140627151542.GL32514@n2100.arm.linux.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King - ARM Linux <linux@arm.linux.org.uk> Data: Friday, June 27, 2014 11:16 PM
>To: linux-arm-kernel@lists.infradead.org; netdev@vger.kernel.org
>Cc: Duan Fugang-B38611
>Subject: [PATCH CFT 00/30] Initial round of Freescale FEC ethernet patches
>
>This is v2 of my initial round of patches (roughly half of my total patch
>set) for the Freescale FEC driver.
>
>I'm sending this set out for comments and testing.  So far, I have had
>only one ack for one patch in this series, this is pretty poor, so I'm now
>sending it with a CFT tag instead.
>
>I haven't changed too much - I've fixed the bug which Andy spotted in the
>transmit handling, but otherwise the patches are much the same.
>
>The remainder of the text is as per my previous message, but with updated
>diffstat:
>
>One of my motivations for only sending half is to get this half into a
>state where DaveM is happy to merge it before I sort out the remainder.
>There's quite a lot here, so bear with me on this.
>
>I've tried to sort the fixes before the cleanups as best I can, but
>reordering the series is a full-time job due to it's size - it's taken
>from Monday until now to get this far with it, so I'm hoping that there
>won't be any "you should rearrange the patches as X" comments.
>
>While the original series was well tested during it's original development,
>including with performance tests on each patch, that testing and
>validation has been lost due to the changes during the last merge window,
>and subsequent rebasing and updating of the patches.
>
>The series is based on v3.16-rc1, and as such, I have added Andy's
>checksum fix to the start of the series.  This patch is not strictly part
>of the RFC, but is included because my complete patch series needs to
>account for that change.
>
>Some of these patches are to fix theoretical problems in the driver (ones
>which have been found via a review of the code) others address real
>observable problems (such as poor half-duplex performance.)
>
>Towards the end of this series, I have included a patch which was
>initially at the beginning of the series for dumping out the state of the
>transmit ring, which is very useful to debug transmit problems.
>This was acceptable when the transmit ring was between 16 and 128
>descriptors, but during the recent merge window, this was increased to
>512 descriptors, so it will now print around 512 lines to the kernel
>message log on transmit timeout.  I'm not entirely convinced this is a
>good idea - maybe it should become optional, or maybe the timed-out ring
>status should be available via debugfs, but that's a problem to retrieve
>if you're running NFS rootfs and the timeout doesn't recover properly.
>
>This series of patches is also available from the following *unstable* git
>branch - unstable as it's provided for convenience so you don't have to
>apply all these patches individually, unstable as the patches need to have
>attributations added, unstable because DaveM will probably want to apply
>them as patches to his tree:
>
>  git://ftp.arm.linux.org.uk/~rmk/linux-arm.git fec-testing
>
> drivers/net/ethernet/freescale/fec.h      |  10 +-
> drivers/net/ethernet/freescale/fec_main.c | 382 +++++++++++++++++--------
>-----
> 2 files changed, 224 insertions(+), 168 deletions(-)
>

Hi, Russell,

The V2 patch set are fine for me. Thanks for your clean for the driver.

Acked-by: Fugang Duan <B38611@freescale.com>

Thanks,
Andy
