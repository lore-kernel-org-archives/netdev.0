From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: 3.0.0rc6: ethtool not working without a cable
Date: Thu, 07 Jul 2011 18:03:54 +0100
Message-ID: <1310058234.3227.0.camel@bwh-desktop>
References: <201107061338.08573.a.miskiewicz@gmail.com>
	 <1309971146.6217.0.camel@jbrandeb-mobl.amr.corp.intel.com>
	 <201107061857.21206.a.miskiewicz@gmail.com>
	 <201107071847.14362.a.miskiewicz@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	e1000-devel <e1000-devel@lists.sourceforge.net>
To: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:7915 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754444Ab1GGRD5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2011 13:03:57 -0400
In-Reply-To: <201107071847.14362.a.miskiewicz@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-07-07 at 18:47 +0200, Arkadiusz Miskiewicz wrote:
> On Wednesday 06 of July 2011, Arkadiusz Miskiewicz wrote:
> > On Wednesday 06 of July 2011, Brandeburg, Jesse wrote:
> > > On Wed, 2011-07-06 at 08:26 -0700, Ben Hutchings wrote:
> > > > On Wed, 2011-07-06 at 16:53 +0200, Arkadiusz Miskiewicz wrote:
> > > > > On Wednesday 06 of July 2011, Ben Hutchings wrote:
> > > > > > On Wed, 2011-07-06 at 13:38 +0200, Arkadiusz Miskiewicz wrote:
> > > > > > > 3.0.0rc6, thinkpad t400 notebook.
> > > > > > > 
> > > > > > > If there is no cable then ethtool reports no device. It wasn't
> > > > > > > that before AFAIK.
> > > > > > > 
> > > > > > > ethtool version 2.6.36
> > > 
> > > snip
> > > 
> > > > Then the only other explanation I can think of is that the driver has
> > > > 'detached' the device due to some kind of error.  The ethtool core does
> > > > have a check for that.
> > > 
> > > could it be that aspm is enabled
> > 
> > I have CONFIG_PCIEASPM=y
> > 
> > > or that you've enabled runtime power
> > > management?
> > 
> > In e1000e? no (unless it's default somehow).
> 
> And if this is normal behaviour (when apsm is enabled) then maybe ethtool 
> could disable apsm/power management for device for time of querying?

No, it's a driver bug if the device comes up in a 'detached' state.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

