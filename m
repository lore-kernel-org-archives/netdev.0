From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 0/4] Support the MX6 FEC as a PTP hardware clock
Date: Fri, 2 Nov 2012 23:25:28 +0000
Message-ID: <1351898728.2703.30.camel@bwh-desktop.uk.solarflarecom.com>
References: <1351657480-24745-1-git-send-email-Frank.Li@freescale.com>
	 <20121101.123027.1332984905040252720.davem@davemloft.net>
	 <CAHrpEqRuy=kewK-592RphVfJnNoma2CPZytoTqLc45HeT53hRQ@mail.gmail.com>
	 <20121102084324.GA2486@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <Frank.Li@freescale.com>,
	<shawn.guo@linaro.org>, <linux-arm-kernel@lists.infradead.org>,
	<netdev@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>,
	Frank Li <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:22553 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752920Ab2KBXZc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2012 19:25:32 -0400
In-Reply-To: <20121102084324.GA2486@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-11-02 at 09:43 +0100, Richard Cochran wrote:
> On Fri, Nov 02, 2012 at 10:36:09AM +0800, Frank Li wrote:
> > >
> > > All applied to net-next.
> > >
> > > Please make sure your changes are in sync with Ben's PTP/PPS
> > > Kconfig changes of today, and send me any changes if necessary.
> > >
> > 
> > Thank you very much.
> > I checked Ben's patch, which not affect FEC.
> 
> Maybe just remove the Kconfig line "select PPS".

More than that: FEC should select PTP_1588_CLOCK, FEC_PTP should be
removed and all the conditional code made unconditional.  Alternately,
if that would cost too much (in terms of performance or memory) on some
systems where the driver is used, FEC_PTP should default to 'y'.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
