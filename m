From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] gianfar_ptp: use iomem, not ioports resource tree in
 probe
Date: Wed, 24 Oct 2012 21:42:08 +0200
Message-ID: <20121024194207.GA2732@netboy.at.omicron.at>
References: <1351092096-14811-1-git-send-email-paul.gortmaker@windriver.com>
 <6AE080B68D46FC4BA2D2769E68D765B70810B134@039-SN2MPN1-023.039d.mgd.msft.net>
 <50883D03.1000600@windriver.com>
 <50883DB7.4030502@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Yang <Wei.Yang@windriver.com>,
	Manoil Claudiu-B08782 <B08782@freescale.com>
To: Timur Tabi <B04825@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:63289 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933818Ab2JXTmR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2012 15:42:17 -0400
Received: by mail-we0-f174.google.com with SMTP id t9so457550wey.19
        for <netdev@vger.kernel.org>; Wed, 24 Oct 2012 12:42:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <50883DB7.4030502@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 24, 2012 at 02:12:55PM -0500, Timur Tabi wrote:
> Paul Gortmaker wrote:
> > Even if it makes sense to convert the driver to of_xxx calls,
> > I think the obvious bug should be fixed as a separate commit,
> > so that the -stable folks have something to cherry pick.
> 
> Oh, I agree with that.  I was just wondering why an OF-enabled driver
> would not use OF calls.  I've never seen that before.  My instinct is that
> the original developer had no idea what he was doing, but perhaps there is
> a very good reason for the way the driver is written.

Instead of using your instinct, try using your brain instead.

Thanks,
Richard
