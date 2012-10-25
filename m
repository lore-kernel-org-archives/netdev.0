From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] gianfar_ptp: use iomem, not ioports resource tree in
 probe
Date: Thu, 25 Oct 2012 22:08:54 +0200
Message-ID: <20121025200853.GA6151@netboy.at.omicron.at>
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
Received: from mail-wg0-f44.google.com ([74.125.82.44]:35895 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760158Ab2JYUJG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 16:09:06 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr13so1603397wgb.1
        for <netdev@vger.kernel.org>; Thu, 25 Oct 2012 13:09:05 -0700 (PDT)
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

Getting back to your really ignorant comment, I suggest that you look
at this review. It was made by Grant Likely. Perhaps you have heard of
him?

  https://lkml.org/lkml/2011/2/23/281

I was the original developer of the PTP code, and my code went through
fifteen rounds of review. And guess what - I actually listened to the
reviewer's comments and changed my work accordingly.

You can read all about what happened, but you will have to find v15
yourself. Be sure to pay special attention to the history of
irq_of_parse_and_map() verses platform_get_irq().

Or maybe your instinct was right, and I don't know what I am doing.

   - [V14] http://lkml.org/lkml/2011/4/18/16
   - [V13] http://lkml.org/lkml/2011/3/27/2
   - [V12] http://lkml.org/lkml/2011/2/28/53
   - [V11] http://lkml.org/lkml/2011/2/23/107
   - [V10] http://lkml.org/lkml/2011/1/27/71
   - [V9]  http://lkml.org/lkml/2011/1/13/65
   - [V8]  http://lkml.org/lkml/2010/12/31/128
   - [V7]  http://lkml.org/lkml/2010/12/16/195
   - [V6]  http://lkml.org/lkml/2010/9/23/310
   - [V5]  http://lkml.org/lkml/2010/8/16/90
   - Thomas Gleixner: Rework of the PTP support series core code
     http://lkml.org/lkml/2011/2/1/137
   - Dynamic clock devices [RFC]
     http://lkml.org/lkml/2010/11/4/290
   - POSIX clock tuning syscall with dynamic clock ids
     http://lkml.org/lkml/2010/9/3/119
   - POSIX clock tuning syscall with static clock ids
     http://lkml.org/lkml/2010/8/23/49
   - Versions 1-4 appeared on the netdev list.

Thanks,
Richard
