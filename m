From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH 07/10] ixgbe: Add function for setting XPS queue
 mapping
Date: Wed, 11 Jul 2012 19:15:07 +0100
Message-ID: <1342030507.2613.46.camel@bwh-desktop.uk.solarflarecom.com>
References: <20120630000652.29939.11108.stgit@gitlad.jf.intel.com>
	 <20120630001649.29939.725.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<jeffrey.t.kirsher@intel.com>, <edumazet@google.com>,
	<therbert@google.com>, <alexander.duyck@gmail.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:15518 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754672Ab2GKSPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 14:15:12 -0400
In-Reply-To: <20120630001649.29939.725.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-06-29 at 17:16 -0700, Alexander Duyck wrote:
> This change adds support for ixgbe to configure the XPS queue mapping on
> load.  The result of this change is that on open we will now be resetting
> the number of Tx queues, and then setting the default configuration for XPS
> based on if ATR is enabled or disabled.
[...]

I didn't see where you're resetting the number of TX queues; was that
actually added in an earlier patch?

It seems strange to be resetting XPS configuration on open; normally net
device configuration persists as long as the device is registered.
Maybe only do this if the number of TX queues has to change?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
