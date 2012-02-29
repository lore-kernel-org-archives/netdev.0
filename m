From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] mdio: Export mdio.h to userland
Date: Wed, 29 Feb 2012 22:43:48 +0000
Message-ID: <1330555428.5881.8.camel@bwh-desktop>
References: <1330542122.5881.2.camel@bwh-desktop>
	 <1330542754.5881.4.camel@bwh-desktop>
	 <20120229.154227.908693909825012701.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:54481 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756596Ab2B2Wnw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 17:43:52 -0500
In-Reply-To: <20120229.154227.908693909825012701.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-02-29 at 15:42 -0500, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Wed, 29 Feb 2012 19:12:34 +0000
> 
> > On Wed, 2012-02-29 at 19:02 +0000, Ben Hutchings wrote:
> >> The ID packing/unpacking functions are needed by userland and the
> >> register definitions may also be useful there.
> > 
> > Minor issue with this: mdio_phy_id_is_c45() returns bool, and that's not
> > defined by default.  Should I add #include <stdbool.h> or change the
> > return type to int for maximum compatibility?
> 
> I do not see any precedence for including stdbool.h in a kernel header
> file.  And I sure as hell am not going to compromise using a correct
> type just to make this usable by userspace.
> 
> I think this is of dubious value, and combined with the bool
> complication I'm not going to apply this, sorry.

Without this, userland doing clause 45 MDIO has to duplicate the ID
packing definitions.   I intended to export these to userland in the
first place; that's why the header already has an #ifdef __KERNEL__.
I was about to get rid of the duplicate definitions in our utilities
when I realised I hadn't exported them.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
