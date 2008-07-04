From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Date: Fri, 04 Jul 2008 21:53:47 +0100
Message-ID: <1215204827.3189.13.camel@shinybook.infradead.org>
References: <1215177044.10393.743.camel@pmac.infradead.org>
	 <486E2260.5050503@garzik.org>
	 <1215178035.10393.763.camel@pmac.infradead.org>
	 <20080704.133721.98729739.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, andi@firstfloor.org, tytso@mit.edu,
	hugh@veritas.com, akpm@linux-foundation.org,
	kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:38911 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752581AbYGDUyA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2008 16:54:00 -0400
In-Reply-To: <20080704.133721.98729739.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-07-04 at 13:37 -0700, David Miller wrote:
> And for one, I have consistently argued that this "best practice" is
> the "worst practice" from a technical perspective.  It is the worst
> because it means mistakes are possible to make between driver and
> firmware versions.  Even with versioning it is not fool proof.
> Whereas if you link the firmware into the driver, it's impossible to
> get wrong.

And you've been wrong about that from the start, which is why the rest
of the kernel has moved on while the drivers you control are left
behind.

But we've already stopped working on drivers/net; we're fixing the rest
of the older drivers first. And every affected maintainer except you and
Jeff seems _happy_ to see their drivers being brought up to date.

-- 
dwmw2

