From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Date: Sun, 06 Jul 2008 23:10:25 +0100
Message-ID: <1215382225.3189.174.camel@shinybook.infradead.org>
References: <1215178035.10393.763.camel@pmac.infradead.org>
	 <486E2818.1060003@garzik.org> <20080704142753.27848ff8@lxorguk.ukuu.org.uk>
	 <20080704.134329.209642254.davem@davemloft.net>
	 <20080704220444.011e7e61@lxorguk.ukuu.org.uk>
	 <alpine.DEB.1.10.0807061311030.11010@asgard.lang.hm>
	 <1215376034.3189.127.camel@shinybook.infradead.org>
	 <alpine.DEB.1.10.0807061351040.11010@asgard.lang.hm>
	 <1215377814.3189.137.camel@shinybook.infradead.org>
	 <48713B73.6030708@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: david@lang.hm, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	David Miller <davem@davemloft.net>, andi@firstfloor.org,
	tytso@mit.edu, hugh@veritas.com, akpm@linux-foundation.org,
	kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:41105 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756588AbYGFWKm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2008 18:10:42 -0400
In-Reply-To: <48713B73.6030708@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2008-07-06 at 17:38 -0400, Jeff Garzik wrote:
> David Woodhouse wrote:
> > On Sun, 2008-07-06 at 13:52 -0700, david@lang.hm wrote:
> >> On Sun, 6 Jul 2008, David Woodhouse wrote:
> >>
> >>> On Sun, 2008-07-06 at 13:17 -0700, david@lang.hm wrote:
> >>>> if David W were to make it possible to not use the load_firmware() call to
> >>>> userspace and build the firmware into the driver (be it in a monolithic
> >>>> kernel or the module that contains the driver)
> >>> You _can_ build the firmware into the kernel.
> >> right, but not into a module. you have half of the answer in place, but 
> >> not all of it.
> > 
> > The useful half. If you have userspace to load modules, you have
> > userspace to load firmware too.
> 
> Existing examples have already been provided where this logic fails.

I even provided such an example, where your script greps the module for
'request_firmware' and fails if there's a match. I don't think any of
the other provided examples were _much_ more sensible than that...

-- 
dwmw2

