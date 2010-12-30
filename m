From: Hans Ulli Kroll <ulli.kroll@googlemail.com>
Subject: Re: [PATCH v4] Gemini: Gigabit ethernet driver
Date: Thu, 30 Dec 2010 12:48:47 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1012301236400.18031@localhost>
References: <20101230083905.5A8EB13909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-1954756097-1293709732=:18031"
Cc: Hans Ulli Kroll <ulli.kroll@googlemail.com>,
	gemini-board-dev@lists.berlios.de, netdev@vger.kernel.org,
	Christoph Biedl <linux-kernel.bfrz@manchmal.in-ulm.de>
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:59751 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751509Ab0L3Lsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Dec 2010 06:48:55 -0500
Received: by bwz15 with SMTP id 15so11646138bwz.19
        for <netdev@vger.kernel.org>; Thu, 30 Dec 2010 03:48:54 -0800 (PST)
In-Reply-To: <20101230083905.5A8EB13909@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-1954756097-1293709732=:18031
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT



On Thu, 30 Dec 2010, Michał Mirosław wrote:

> Driver for SL351x (Gemini) SoC ethernet peripheral. Based in part
> on work by Paulius Zaleckas and GPLd code from Raidsonic and other
> NAS vendors.
> 
> Tested on Raidsonic IcyBox 4220-B (dual SATA NAS).
> 
> Signed-off-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>
> ---
> 

Hi Michał,

I've make a quick compile and run test on my IB4220
Looks good.

But we must include the file gmac.h from 
arch/arm/mach-gemini/include/mach.
We break the build, if we don't do this.

Other issue is the __raw_writel and __raw_readl functions, we can switch 
to readl and writel. This is due some mistake of the original developer 
(Stormlinksemi) who doesn't understand endianes on ARM

I've tested this driver on my IB4220 only in 100MBit/s mode. PHY is broken.

I have another IB4220 at my home with working PHY

Ulli


--8323328-1954756097-1293709732=:18031--
