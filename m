From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Fix deadlock between boomerang_interrupt and
	boomerang_start_tx in 3c59x
Date: Fri, 13 Aug 2010 11:15:56 -0400
Message-ID: <20100813151556.GA27733@gondor.apana.org.au>
References: <20100811120900.3629706c@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:56771 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755092Ab0HMPQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Aug 2010 11:16:06 -0400
Content-Disposition: inline
In-Reply-To: <20100811120900.3629706c@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> wrote:
>
> I thought we agreed that any device supporting netconsole agrees
> to not call printk in the transmit path. Just kill the pr_* call.

Not calling printk from the driver doesn't help since you can
still call printk from an IRQ handler.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
