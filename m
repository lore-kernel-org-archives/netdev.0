From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] SMC on pxa3xx (was: pxa3xx base patch [5/5] - net)
Date: Fri, 27 Apr 2007 11:03:19 +0200
Message-ID: <20070427090319.GE19539@xi.wantstofly.org>
References: <1177663928.4307.7.camel@diimka.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nico@cam.org
To: dmitry pervushin <dpervushin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:37089 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755498AbXD0JDY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2007 05:03:24 -0400
Content-Disposition: inline
In-Reply-To: <1177663928.4307.7.camel@diimka.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 27, 2007 at 12:52:08PM +0400, dmitry pervushin wrote:

> +#elif defined(CONFIG_PXA3xx)
> +#define SMC_CAN_USE_8BIT	1
> +#define SMC_CAN_USE_16BIT	1
> +#define SMC_CAN_USE_32BIT	0
> +#define SMC_IO_SHIFT		0
> +#define SMC_NOWAIT		1
> +#define SMC_USE_PXA_DMA		1
> +#define SMC_inb(a, r)		readb((a) + (r))
> +#define SMC_outb(v, a, r)	writeb(v, (a) + (r))
> +#define SMC_inw(a, r)		readw((a) + (r))
> +#define SMC_outw(v, a, r)	writew(v, (a) + (r))
> +#define SMC_insw(a, r, p, l)	insw((a) + (r), p, l)
> +#define SMC_outsw(a, r, p, l)	outsw((a) + (r), p, l)

This is bogus, please don't apply.

The fact that the SMC might be hooked up in a certain way on one
certain PXA3xx board doesn't mean that it will be hooked up in that
way on every PXA3xx board.

Everything I've seen of the PXA3xx patch set so far is a disaster.
MontaVista is flooding every corner of the internet with these crap
patches.  This idiocy has got to stop.
