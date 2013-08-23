From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH RESEND net-next 06/16] sfc: Introduce and use
 MCDI_DECLARE_BUF macro
Date: Fri, 23 Aug 2013 11:26:10 +0100
Message-ID: <1377253570.2586.15.camel@deadeye.wl.decadent.org.uk>
References: <1377199326.1703.49.camel@bwh-desktop.uk.level5networks.com>
	 <1377199609.1703.55.camel@bwh-desktop.uk.level5networks.com>
	 <20130822.220236.2202751653391527307.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:11851 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754313Ab3HWK0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 06:26:14 -0400
In-Reply-To: <20130822.220236.2202751653391527307.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-08-22 at 22:02 -0700, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Thu, 22 Aug 2013 20:26:49 +0100
> 
> > MCDI_DECLARE_BUF declares a variable as an MCDI buffer of the
> > requested length, adding any necessary padding.
> > 
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> 
> There really isn't a guarentee that a u8 array is going to
> aligned appropriately to write dwords there using casts like
> you do.

Yes, but this has been wrong for years.

> Since you're here macro'izing the declaration, take the time to fix it
> to specify the necessary alignment as well.
[...]

My intent was to separate refactoring changes with no immediate effect
(#6-9) from functional changes (#10-11), making them easier to review.
The alignment gets fixed by #11.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
