From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 4/4] igb: enable auxiliary PHC functions for
 the i210.
Date: Wed, 29 May 2013 21:32:10 +0100
Message-ID: <1369859530.1971.29.camel@bwh-desktop.uk.level5networks.com>
References: <20130528162325.GD4678@netboy>
	 <CDCA3AA1.1E8D4%matthew.vick@intel.com>
	 <02874ECE860811409154E81DA85FBB58564F1C88@ORSMSX104.amr.corp.intel.com>
	 <20130529072445.GA4868@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Keller, Jacob E" <jacob.e.keller@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:14961 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966083Ab3E2UcP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 16:32:15 -0400
In-Reply-To: <20130529072445.GA4868@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-29 at 09:24 +0200, Richard Cochran wrote:
> On Tue, May 28, 2013 at 09:12:02PM +0000, Keller, Jacob E wrote:
> > 
> > I think ethtool would be good, but what about using sysfs?
> 
> The problem I see with ethtool is that configuring GPIOs (and these
> SDPs are really just GPIOs by a different name) is really the job of
> the device tree. But of course, most x86 users of the i210 don't have
> this option.
> 
> Also, using ethtool or sysfs is not really attractive for embedded
> designs (let's not forget the poor embedded guys). I think we need to
> have a way to specify the pin functions at (or before) kernel boot
> time.  Barring DT and kconfig, using a module parameter is the only
> way to accomplish this.

On x86 the correct place to put this information would presumably be an
ACPI table.  And if the BIOS doesn't provide it, there is
CONFIG_ACPI_CUSTOM_DSDT, though that may be a bit of a sledgehammer...

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
