From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 0/3] Enable PPS and PTP clocks automatically
Date: Thu, 1 Nov 2012 16:46:56 +0000
Message-ID: <1351788416.2883.6.camel@bwh-desktop.uk.solarflarecom.com>
References: <1351733397.2706.62.camel@bwh-desktop.uk.solarflarecom.com>
	 <20121101081924.GB2637@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Rodolfo Giometti <giometti@enneenne.com>,
	<netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:46392 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932447Ab2KAQrF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2012 12:47:05 -0400
In-Reply-To: <20121101081924.GB2637@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-11-01 at 09:19 +0100, Richard Cochran wrote:
> Ben,
> 
> I really like this idea, but I have a couple of questions, below.
> 
> On Thu, Nov 01, 2012 at 01:29:57AM +0000, Ben Hutchings wrote:
> 
> > Ben Hutchings (3):
> >   pps, ptp: Remove dependencies on EXPERIMENTAL
> 
> Kees Cook just posted a massive series to remove EXPERIMENTAL
> everywhere. Maybe it would make sense to have this series follow that
> one?

If some other tree gets a commit to remove these, they should still
merge cleanly.

> >   ptp: Make PTP_1588_CLOCK select rather than depend on PPS
> >   ptp: Enable clock drivers along with associated net/PHY drivers
> > 
> >  drivers/net/ethernet/intel/Kconfig                 |   28 +------------------
> >  drivers/net/ethernet/intel/igb/Makefile            |    4 +--
> >  drivers/net/ethernet/intel/igb/igb.h               |    6 ----
> >  drivers/net/ethernet/intel/igb/igb_ethtool.c       |    2 -
> >  drivers/net/ethernet/intel/igb/igb_main.c          |   28 --------------------
> 
> The #ifdefs in the Intel and PCH drivers are meant to streamline the
> code for users who are not interested in time stamping. Although the
> overhead of the additional is minimal (it really just a bunch of
> tests), and I wouldn't mind removing the conditionals, I suspect that
> some people won't like it.

Then they may object to this and maybe get some drivers changed back.
However I didn't get any objections when I previously outlined these
changes.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
