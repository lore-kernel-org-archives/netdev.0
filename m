From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 3/4] net: ethernet: ti cpsw: Split up DMA descriptor pool
Date: Fri, 18 Jan 2013 17:14:04 +0000 (UTC)
Message-ID: <loom.20130118T181133-844@post.gmane.org>
References: <1358503572-5057-1-git-send-email-sebastian@breakpoint.cc> <1358503572-5057-3-git-send-email-sebastian@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:58153 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751541Ab3ARRTv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2013 12:19:51 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1TwFbo-0000wR-LY
	for netdev@vger.kernel.org; Fri, 18 Jan 2013 18:20:05 +0100
Received: from ABTS-KK-dynamic-108.182.166.122.airtelbroadband.in ([ABTS-KK-dynamic-108.182.166.122.airtelbroadband.in])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 18 Jan 2013 18:20:04 +0100
Received: from mugunthanvnm by ABTS-KK-dynamic-108.182.166.122.airtelbroadband.in with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 18 Jan 2013 18:20:04 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sebastian Andrzej Siewior <sebastian <at> breakpoint.cc> writes:

> 
> From: Thomas Gleixner <tglx <at> linutronix.de>
> 
> Split the buffer pool into a RX and a TX block so neither of the
> channels can influence the other. It is possible to fillup the pool by
> sending a lot of large packets on a slow half-duplex link.
> 
> Cc: Rakesh Ranjan <rakesh.ranjan <at> vnl.in>
> Cc: Bruno Bittner <Bruno.Bittner <at> sick.com>
> Signed-off-by: Thomas Gleixner <tglx <at> linutronix.de>
> [dengler: patch description]
> Signed-off-by: Holger Dengler <dengler <at> linutronix.de>
> [jan: forward ported]
> Signed-off-by: Jan Altenberg <jan <at> linutronix.de>
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy <at> linutronix.de>
> ---
>  drivers/net/ethernet/ti/davinci_cpdma.c |   35 +++++++++++++++++++++++++++---
>  1 files changed, 31 insertions(+), 4 deletions(-)
> 

The same patch i have posted in the following patch series and its under review.
http://patchwork.ozlabs.org/patch/213322/

Regards
Mugunthan V N
