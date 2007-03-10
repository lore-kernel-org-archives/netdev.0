From: Christoph Hellwig <hch@infradead.org>
Subject: Re: SSB/b44 build failure
Date: Sat, 10 Mar 2007 18:05:42 +0000
Message-ID: <20070310180541.GA17160@infradead.org>
References: <1173496449.13449@shark.he.net> <20070310150346.GB5062@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Randy Dunlap <rdunlap@xenotime.net>, mb@bu3sch.de, bunk@stusta.de,
	netdev@vger.kernel.org, akpm@linux-foundation.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:33791 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750808AbXCJSGR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Mar 2007 13:06:17 -0500
Content-Disposition: inline
In-Reply-To: <20070310150346.GB5062@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 10, 2007 at 10:03:46AM -0500, John W. Linville wrote:
> FWIW, this is coming from the port of b44 to use the SSB bus which
> I'm carrying in the wireless-dev tree.
> >
> SSB (i.e. "Sonics Silicon Backplane") is a bus used in Broadcom SoCs
> including the b44 and bcm43xx hardware.  The SSB bus driver and the
> b44 port to SSB is being developed by Michael Buesch, the maintainer of
> the bcm43xx driver.  I've been carrying the b44 SSB port in my tree for
> Michael's convenience.  Just an FYI for those wondering what SSB is...

Btw, what's the reason this is in wireless-dev?  Could we please merge
this code into mainline soonish (aka 2.6.22) instead of interwinding
it with totally unrelated wireless changes?

