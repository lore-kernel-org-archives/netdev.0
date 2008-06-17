From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH] firmware: convert acenic driver to request_firmware()
Date: Tue, 17 Jun 2008 17:52:45 +0100
Message-ID: <1213721565.26255.1097.camel@pmac.infradead.org>
References: <1213608300.26255.665.camel@pmac.infradead.org>
	 <18518.37862.812419.353804@jaguar.mkp.net>
	 <1213636990.26255.822.camel@pmac.infradead.org>
	 <18519.60265.235564.200017@jaguar.mkp.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jaswinder@infradead.org
To: Jes Sorensen <jes@trained-monkey.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:36794 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754030AbYFQQwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 12:52:49 -0400
In-Reply-To: <18519.60265.235564.200017@jaguar.mkp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-06-17 at 12:50 -0400, Jes Sorensen wrote:
> >>>>> "David" == David Woodhouse <dwmw2@infradead.org> writes:
> 
> David> On Mon, 2008-06-16 at 12:25 -0400, Jes Sorensen wrote:
> David> We don't have hardware, so haven't been able to test it on either
> David> little-endian or big-endian machines, but we took care to ensure
> David> that it should work on both.
> 
> Hmmm, I have the cards, but no BE boxes to plug them into - stop by and
> I'll give you one :-)

Should have suggested that last week when I was unemployed :)

> David> Since the CPU on the device is big-endian, I would be amenable to
> David> an argument that we should store the firmware in its native
> David> big-endian form, and load it with writel(be32_to_cpu()) instead.
> 
> David> It doesn't matter much either way, really.
> 
> I'm not really biased, the card isn't in production anymore and there's
> fewer and fewer of them out there. As long as it works it's fine with
> me, but I guess I have a slight preference for staying as close to the
> original format as possible.

OK, we'll switch to BE, to be closer to the original form of the
firmware.

-- 
dwmw2

