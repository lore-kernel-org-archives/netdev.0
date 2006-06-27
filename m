From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] smc91x: disable DMA mode on the logicpd pxa270
Date: Tue, 27 Jun 2006 04:14:42 +0200
Message-ID: <20060627021442.GA20421@xi.wantstofly.org>
References: <20060623212436.GB4843@xi.wantstofly.org> <44A091CC.90607@pobox.com> <20060627020831.GA20393@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nico@cam.org, mikee@logicpd.com,
	peterb@logicpd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:4288 "EHLO
	xi.wantstofly.org") by vger.kernel.org with ESMTP id S933236AbWF0COn
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 22:14:43 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20060627020831.GA20393@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 27, 2006 at 04:08:31AM +0200, Lennert Buytenhek wrote:

> Hmmm, non-quilt style patch better?

I might have an idea what's happening -- the last context line in the
patch should have been a blank line, but it's being eaten somewhere in
transit.

> -#define SMC_inb(a, r)		readb((a) + (r))
>  #define SMC_inw(a, r)		readw((a) + (r))
> -#define SMC_inl(a, r)		readl((a) + (r))
> -#define SMC_outb(v, a, r)	writeb(v, (a) + (r))
>  #define SMC_outw(v, a, r)	writew(v, (a) + (r))
> -#define SMC_outl(v, a, r)	writel(v, (a) + (r))
>  #define SMC_insw(a, r, p, l)	readsw((a) + (r), p, l)
>  #define SMC_outsw(a, r, p, l)	writesw((a) + (r), p, l)

<=== there should have been a blank line here

> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Not sure what is causing this.  Can you take it from here?

	http://www.wantstofly.org/~buytenh/smc91-diff-lpd.diff


thanks,
Lennert
