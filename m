From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH 4/4] FEC: Add time stamping code and a PTP hardware clock
Date: Mon, 17 Dec 2012 21:02:32 +0100
Message-ID: <20121217200232.GS26326@pengutronix.de>
References: <1351657531-25989-1-git-send-email-Frank.Li@freescale.com>
 <20121217091345.GA753@pengutronix.de>
 <CAHrpEqTVuSR_-Tpdzb98=VJbg7grSFvSQ9xA6mPsHpGb7RvNCg@mail.gmail.com>
 <20121217151445.GA17907@S2101-09.ap.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frank Li <lznuaa@gmail.com>, Frank Li <Frank.Li@freescale.com>,
	lznua@gmail.com, richardcochran@gmail.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	davem@davemloft.net
To: Shawn Guo <shawn.guo@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:46868 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752276Ab2LQUCk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2012 15:02:40 -0500
Content-Disposition: inline
In-Reply-To: <20121217151445.GA17907@S2101-09.ap.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 17, 2012 at 11:14:46PM +0800, Shawn Guo wrote:
> Hi Sascha,
> 
> On Mon, Dec 17, 2012 at 10:48:31PM +0800, Frank Li wrote:
> > > I don't know how to continue from here. Since the whole patch doesn't
> > > seem to reviewed very much I tend to say we should revert it for now and
> > > let Frank redo it for the next merge window.
> > >
> > > Other opinions?
> > 
> > Can we just disable CONFIG_FEC_PTP defaut instead of revert whole patch?
> > 
> To be clear, the following is what Frank meant.  Since Frank is out of
> office for some time, I will send this immediate fix to David, if you
> are fine with it.

This leaves an option in the tree which can be used to break FEC on
i.MX3/5.

	depends on !SOC_IMX31 && !SOC_IMX35 && !SOC_IMX5

might be an option, but given that this patch seems to have bypassed any
review I feel more like reverting it.

Sascha


-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
