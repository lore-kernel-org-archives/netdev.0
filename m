From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 4/4] FEC: Add time stamping code and a PTP hardware
 clock
Date: Wed, 19 Dec 2012 15:53:20 +0000
Message-ID: <20121219155319.GP13292@decadent.org.uk>
References: <1351657531-25989-1-git-send-email-Frank.Li@freescale.com>
 <20121217091345.GA753@pengutronix.de>
 <CAHrpEqTVuSR_-Tpdzb98=VJbg7grSFvSQ9xA6mPsHpGb7RvNCg@mail.gmail.com>
 <20121217151445.GA17907@S2101-09.ap.freescale.net>
 <20121217200232.GS26326@pengutronix.de>
 <20121218070420.GA2946@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Richard Cochran <richardcochran@gmail.com>,
	Shawn Guo <shawn.guo@linaro.org>, Frank Li <lznuaa@gmail.com>,
	lznua@gmail.com, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, davem@davemloft.net
To: Frank Li <Frank.Li@freescale.com>,
	Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:54909 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751387Ab2LSPxc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 10:53:32 -0500
Content-Disposition: inline
In-Reply-To: <20121218070420.GA2946@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 18, 2012 at 08:04:20AM +0100, Richard Cochran wrote:
> On Mon, Dec 17, 2012 at 09:02:32PM +0100, Sascha Hauer wrote:
> > This leaves an option in the tree which can be used to break FEC on
> > i.MX3/5.
> > 
> > 	depends on !SOC_IMX31 && !SOC_IMX35 && !SOC_IMX5
> > 
> > might be an option, but given that this patch seems to have bypassed any
> > review I feel more like reverting it.
> 
> Instead of reverting, I suggest finding a solution (Frank) to let the
> code work when it can work and to prevent it when it cannot. This
> could be kconfig, DT, or run time probing of silicon revisions, but I
> don't have access to this hardware, and so I can't really say how to
> fix it.
[...]

Please implement run-time probing.  A different configuration for
each SoC is just not sustainable for distributions.

Ben.

-- 
Ben Hutchings
We get into the habit of living before acquiring the habit of thinking.
                                                              - Albert Camus
