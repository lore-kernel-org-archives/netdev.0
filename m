From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 1/9] sfc: Wait at most 10ms for the MC to
 finish reading out MAC statistics
Date: Fri, 23 Apr 2010 15:36:33 -0700 (PDT)
Message-ID: <20100423.153633.45897185.davem@davemloft.net>
References: <1272061439.5520.14.camel@achroite.uk.solarflarecom.com>
	<1272062009.5520.27.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49812
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750914Ab0DWWg3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 18:36:29 -0400
In-Reply-To: <1272062009.5520.27.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 23 Apr 2010 23:33:28 +0100

> All of these 9 patches should also be applicable to 2.6.33.y, except
> that one hunk of "sfc: Consistently report short MCDI responses as EIO"
> is not applicable and should be dropped.
> 
> Some of the bug fixes are applicable to 2.6.32.y and maybe to 2.6.27.y,
> but the patches will need some adjustment.  I intend to send backported
> patches to stable@kernel.org separately.

There is zero way I'm applying 9 patches this late in the RC
series.

If you want this stuff to go into net-2.6 and get backported
to -stable, pick a very small (2 or 3) set of the most important
fixes.

Consistent -EIO error code returns and junk like that are
not appropriate this late in the RC, and definitely not -stable
material.
