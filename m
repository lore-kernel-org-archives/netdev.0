From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Should "N/A" dust bunnies be swept from fw_version?
Date: Fri, 18 Nov 2011 00:19:34 +0000
Message-ID: <1321575574.2749.55.camel@bwh-desktop>
References: <4EC5984D.5070501@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:29105 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751617Ab1KRATi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 19:19:38 -0500
In-Reply-To: <4EC5984D.5070501@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-11-17 at 15:27 -0800, Rick Jones wrote:
> In the discussion on "enable virtio_net to return bus_info in ethtool -i 
> consistent with emulated NICs" Ben Hutchings had the following feedback 
> on what might go into bus_info:
> 
> > Please use the existing 'not implemented' value, which is the empty
> > string.   If you think ethtool should print some helpful message instead
> > of an empty string, please submit a patch for ethtool.
> 
> When I was sweeping in the .get_drvinfo routines, I noticed many drivers 
> would return "N/A" for fw_version - presumably they were drivers for 
> cards without firmware.  Should those be removed to have the fw_version 
> be the empty string, or should those sleeping dust bunnies be allowed to 
> lie?

I much prefer the empty string; the ethtool utility can turn that into a
user-friendly placeholder if it's considered confusing.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
