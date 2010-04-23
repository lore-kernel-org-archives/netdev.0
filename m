From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-2.6 1/9] sfc: Wait at most 10ms for the MC to
 finish reading out MAC statistics
Date: Fri, 23 Apr 2010 23:54:30 +0100
Message-ID: <1272063270.5520.39.camel@achroite.uk.solarflarecom.com>
References: <1272061439.5520.14.camel@achroite.uk.solarflarecom.com>
	 <1272062009.5520.27.camel@achroite.uk.solarflarecom.com>
	 <20100423.153633.45897185.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:48053 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752099Ab0DWWye (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 18:54:34 -0400
In-Reply-To: <20100423.153633.45897185.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-04-23 at 15:36 -0700, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Fri, 23 Apr 2010 23:33:28 +0100
> 
> > All of these 9 patches should also be applicable to 2.6.33.y, except
> > that one hunk of "sfc: Consistently report short MCDI responses as EIO"
> > is not applicable and should be dropped.
> > 
> > Some of the bug fixes are applicable to 2.6.32.y and maybe to 2.6.27.y,
> > but the patches will need some adjustment.  I intend to send backported
> > patches to stable@kernel.org separately.
> 
> There is zero way I'm applying 9 patches this late in the RC
> series.
> 
> If you want this stuff to go into net-2.6 and get backported
> to -stable, pick a very small (2 or 3) set of the most important
> fixes.

This makes no sense.  You want to put a quota on bug fixes?  I could
arbitrarily pick some but I'm still going to want to get the other fixes
into distributions.

> Consistent -EIO error code returns and junk like that are
> not appropriate this late in the RC, and definitely not -stable
> material.

The important part of that change is that functions were returning 0 in
a failure case.  I should have made that the first sentence in the
commit message.  I didn't see the point in making a separate commit to
fix the wrong error codes, but I can split this up if you prefer.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

