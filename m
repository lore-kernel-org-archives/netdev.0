From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 13/13] igb: Store the MAC address in the name in the
 PTP struct.
Date: Thu, 23 Aug 2012 22:35:37 +0100
Message-ID: <1345757737.2579.22.camel@bwh-desktop.uk.solarflarecom.com>
References: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1345715813-20757-14-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20120823104554.GA2238@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, <davem@davemloft.net>,
	Matthew Vick <matthew.vick@intel.com>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>,
	<sassmann@redhat.com>, Stuart Hodgson <smhodgson@solarflare.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:11368 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756871Ab2HWVfm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 17:35:42 -0400
In-Reply-To: <20120823104554.GA2238@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-08-23 at 12:45 +0200, Richard Cochran wrote:
> On Thu, Aug 23, 2012 at 02:56:53AM -0700, Jeff Kirsher wrote:
> > From: Matthew Vick <matthew.vick@intel.com>
> > 
> > Change the name of the adapter in the PTP struct to enable easier
> > correlation between interface and PTP device.
> 
> You want to put the MAC address into the clock name? This is wrong.
> 
> Besides, there is no need for this. The ethool method already makes
> the correlation crystal clear.

The name field is described as 'A short name to identify the clock'.  It
is not stated whether this is meant to be the name of the clock *device*
or the clock *driver*.  If it's the name of the device then some unique
ID such as the permanent MAC address is required.

The ixgbe driver uses MAC addresses and so did the last submitted
version of PHC support for the sfc driver.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
