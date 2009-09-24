From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH] 3c59x: Get rid of "Trying to free already-free IRQ"
Date: Fri, 25 Sep 2009 01:30:39 +0400
Message-ID: <20090924213039.GA15904@oksana.dev.rtsoft.ru>
References: <20090924183152.GA30254@oksana.dev.rtsoft.ru>
 <200909242230.33881.rjw@sisk.pl>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>,
	linux-pm@lists.linux-foundation.org, netdev@vger.kernel.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ru.mvista.com ([213.79.90.228]:57287 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751698AbZIXVah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2009 17:30:37 -0400
Content-Disposition: inline
In-Reply-To: <200909242230.33881.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 24, 2009 at 10:30:33PM +0200, Rafael J. Wysocki wrote:
> On Thursday 24 September 2009, Anton Vorontsov wrote:
> > Following trace pops up if we try to suspend with 3c59x ethernet NIC
> > brought down:
> 
> Patch looks good, but IMO it'd be a little effort to convert the driver to
> dev_pm_ops while you're at it (please see r8169 for a working example).

I'd like to avoid putting irrelevant stuff into bugfixes.

Apart from delights as bisecting and revert-only-offending-piece,
keeping bugfixes small and self-sufficient helps to back-port the
fixes to stable/distro kernels. Think of not so old kernels that
don't have dev_pm_ops.

Converting this driver (and others that I'm interested in) to
dev_pm_ops is on my todo list though.

Thanks,

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
