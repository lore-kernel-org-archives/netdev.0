From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH][MIPS][7/7] AR7: ethernet
Date: Fri, 7 Sep 2007 09:10:00 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0709070908200.5202@anakin>
References: <200708201704.11529.technoboy85@gmail.com>
 <200709061734.11170.technoboy85@gmail.com> <20070906153025.7cb71cb1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Matteo Croce <technoboy85@gmail.com>, linux-mips@linux-mips.org,
	ejka@imfi.kspu.ru, jgarzik@pobox.com, netdev@vger.kernel.org,
	davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@coreworks.de
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from asia.telenet-ops.be ([195.130.137.74]:50564 "EHLO
	asia.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932679AbXIGHK1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2007 03:10:27 -0400
In-Reply-To: <20070906153025.7cb71cb1.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 6 Sep 2007, Andrew Morton wrote:
> > On Thu, 6 Sep 2007 17:34:10 +0200 Matteo Croce <technoboy85@gmail.com> wrote:
> > Driver for the cpmac 100M ethernet driver.
> > It works fine disabling napi support, enabling it gives a kernel panic
> > when the first IPv6 packet has to be forwarded.
> > Other than that works fine.
> 
> The driver does a lot of open-coded dma_cache_inv() calls (in a way which
> assumes a 32-bit bus, too).  I assume that dma_cache_inv() is some mips

No, even i386 has it ;-)

> thing.  I'd have thought that it would be better to use the dma mapping API
> thoughout the driver, and its associated dma invalidation APIs.

However, Ralf just posted a patch to remove it on all architectures, and
driver writers should consider it gone.

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds
