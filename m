From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: 2.6.28-git8: tg3 doesn't work due to firmware not loading
 (-git7 is ok)
Date: Sun, 11 Jan 2009 22:41:38 +0000
Message-ID: <1231713698.25018.700.camel@macbook.infradead.org>
References: <1231676698.25018.147.camel@macbook.infradead.org>
	 <20090111.133929.57600645.davem@davemloft.net>
	 <1231711347.25018.658.camel@macbook.infradead.org>
	 <20090111.140559.126980927.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Valdis.Kletnieks@vt.edu, alessandro.suardi@gmail.com,
	jaswinderlinux@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:52401 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750893AbZAKWmF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 17:42:05 -0500
In-Reply-To: <20090111.140559.126980927.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-01-11 at 14:05 -0800, David Miller wrote:
> So what used to work out of the box by typing make now
> will have all kinds of strange depencies, right?
> 
> This is a regression, no matter how you spin it, in my
> book.

I know you think that, but I disagree. Yes, it's slightly less
convenient for a small handful of older drivers, but in the general case
it's a massive improvement -- because now we can have a single canonical
location to collect _all_ the firmware that is redistributable, for use
with the kernel. And we've already started adding a whole bunch of new
firmwares to that repository.

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

