From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH v2 2/3] sctp_diag: export timer value only if it is active
Date: Thu, 4 Aug 2016 01:39:32 +0200
Message-ID: <20160803233652.4709D647E4@mail.nwl.cc>
References: <1470259393-22861-1-git-send-email-phil@nwl.cc>
 <1470259393-22861-3-git-send-email-phil@nwl.cc>
 <20160803215115.GE2954@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Xin Long <lucien.xin@gmail.com>, netdev@vger.kernel.org
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:58606 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932493AbcHCXgy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Aug 2016 19:36:54 -0400
Content-Disposition: inline
In-Reply-To: <20160803215115.GE2954@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 03, 2016 at 06:51:15PM -0300, Marcelo Ricardo Leitner wrote:
> On Wed, Aug 03, 2016 at 11:23:12PM +0200, Phil Sutter wrote:
> > Since it is exported as unsigned value, userspace has no way detecting
> > whether it is negative or just very large. Therefore do this in kernel
> > space where it is a simple comparison.
> > 
> > Signed-off-by: Phil Sutter <phil@nwl.cc>
> > ---
> > Changes since v1:
> > - Introduce local variable to shorten long lines.
> > - Use timer_pending() to decide whether to export the timer value.
> > - Export the primary path's value instead of garbage.
> 
> This is now the most important change on the patch IMO. Can we mention
> it on changelog itself?
> 
> A Fixes tag is welcomed too, as previous values were incorrect.

Oh right, thanks for pointing this out. I will follow-up with a fixed
v3.

Thanks, Phil
