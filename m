From: Robert Schwebel <r.schwebel@pengutronix.de>
Subject: Re: [PATCH resend 1/3] Revert "net: fec: fix missing napi_disable
 call"
Date: Fri, 26 Apr 2013 15:44:15 +0200
Message-ID: <20130426134415.GS1366@pengutronix.de>
References: <1366966330-5181-1-git-send-email-l.stach@pengutronix.de>
 <CAHrpEqQLkjCOq0doaM0zNMkgjNkE_pOLxjoFJWNPuQ6CRHCbBw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lucas Stach <l.stach@pengutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Fabio Estevam <festevam@gmail.com>,
	Shawn Guo <shawn.guo@linaro.org>
To: Frank Li <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:37054 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752974Ab3DZNoS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Apr 2013 09:44:18 -0400
Content-Disposition: inline
In-Reply-To: <CAHrpEqQLkjCOq0doaM0zNMkgjNkE_pOLxjoFJWNPuQ6CRHCbBw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Frank,

On Fri, Apr 26, 2013 at 05:32:02PM +0800, Frank Li wrote:
> 2013/4/26 Lucas Stach <l.stach@pengutronix.de>:
> > This reverts commit 3f104c38259dcb3e5443c246f0805bc04d887cc3.
> >
> > In preparaton to revert the other NAPI related changes.
> >
> > Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
>
> David:
>
> Please hold apply this patch for some days.
> Let me found a good way to fix the issue that lucas met.
>
> This patch may cause spin_lock dead lock when using 1588 ptp.

Seriously - it's friday, and 3.9 is expected to come out this weekend.
You broke the driver in mainline with your patches, and the current
state is that it isn't fixable before the release.

So in order not to break the FEC in 3.9-final, please let's go with the
reverts for now; if 1588 PTP is broken, it was broken in 3.8 as well,
correct? After the release, there will be a lot of time to make proper
patches that fix the issues.

rsc
-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
