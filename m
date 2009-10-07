From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethtool: Add reset operation
Date: Wed, 07 Oct 2009 01:29:02 -0700 (PDT)
Message-ID: <20091007.012902.165265462.davem@davemloft.net>
References: <1254776398.2789.7.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46088
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932360AbZJGI3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 04:29:07 -0400
In-Reply-To: <1254776398.2789.7.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 05 Oct 2009 21:59:58 +0100

> After updating firmware stored in flash, users may wish to reset the
> relevant hardware and start the new firmware immediately.  This should
> not be completely automatic as it may be disruptive.
> 
> A selective reset may also be useful for debugging or diagnostics.
> 
> This adds a separate reset operation which takes flags indicating the
> components to be reset.  Drivers are allowed to reset only a subset of
> those requested, and must indicate the actual subset.  This allows the
> use of generic component masks and some future expansion.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
> This differs from the previous (RFC) version only in the semantics of
> the output value of the reset flags: they should indicate the components
> which were *not* reset.  This should be slightly less error-prone as it
> means implementations do not need to maintain the input and output flags
> separately.

Just so my previous reply doesn't confuse, I did apply this version
of the patch.

