From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [BUG] 3.11.5: IPv6 provoked oops?
Date: Fri, 20 Dec 2013 21:43:21 +0100
Message-ID: <20131220204321.GA14073@order.stressinduktion.org>
References: <20131220203115.GL4360@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:43408 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750938Ab3LTUnW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 15:43:22 -0500
Content-Disposition: inline
In-Reply-To: <20131220203115.GL4360@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 20, 2013 at 08:31:16PM +0000, Russell King - ARM Linux wrote:
> So, I'm now running PPPoE on this box, which also does 6to4.  I tried
> to ping another 6to4 address from a box on my lan, which caused this
> oops from 3.11.5:

This should be fixed by the following patches:

http://patchwork.ozlabs.org/patch/288967/
http://patchwork.ozlabs.org/patch/288970/

I think they reached stable already.

Greetings,

  Hannes
