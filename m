From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC NET-NEXT PATCH 0/6] implement MDI-X set support in Intel
 drivers
Date: Wed, 25 Jul 2012 23:48:05 +0100
Message-ID: <1343256485.5132.152.camel@deadeye.wl.decadent.org.uk>
References: <20120725175430.9995.11370.stgit@jbrandeb-snb.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56150 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751548Ab2GYWsJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2012 18:48:09 -0400
In-Reply-To: <20120725175430.9995.11370.stgit@jbrandeb-snb.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-25 at 10:59 -0700, Jesse Brandeburg wrote:
> This is an update (v2) to the patches sent previously.
> 
> This series implements MDI-X set support in the Intel gigabit ethernet
> drivers.  It specifically allows a user to control the MDI state,
> in order for them to work around issues with broken switches.
> 
> The only change to this series is updated descriptions and an
> addition of reporting the current mdix_ctrl value in the
> "get_settings" functions, which allows the new extended reporting
> in the ethtool app's MDI-X: line
> 
> sent as RFC for now to get feedback while internal testing
> completes. (and net-next is closed)
[...]

This all looks sane.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
