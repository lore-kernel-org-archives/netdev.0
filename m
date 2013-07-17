From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [patch net-next RFC 3/3] net: export physical port id via sysfs
Date: Wed, 17 Jul 2013 23:27:34 +0100
Message-ID: <1374100054.3861.18.camel@bwh-desktop.uk.level5networks.com>
References: <1373908027-25800-1-git-send-email-jiri@resnulli.us>
	 <1373908027-25800-4-git-send-email-jiri@resnulli.us>
	 <E31FB011129F30488D5861F383904915210EF3F51F@BLRX7MCDC201.AMER.DELL.COM>
	 <20130717082949.GA1582@minipsycho.orion>
	 <E31FB011129F30488D5861F383904915210EF3F968@BLRX7MCDC201.AMER.DELL.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <jiri@resnulli.us>, <netdev@vger.kernel.org>,
	<john.r.fastabend@intel.com>
To: <Narendra_K@Dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:7721 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755995Ab3GQW1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jul 2013 18:27:39 -0400
In-Reply-To: <E31FB011129F30488D5861F383904915210EF3F968@BLRX7MCDC201.AMER.DELL.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-07-18 at 01:09 +0530, Narendra_K@Dell.com wrote:
> > -----Original Message-----
> > From: Jiri Pirko [mailto:jiri@resnulli.us]
[...]
> > Although this can be done by extending netdevice structure by another item,
> > I believe it is cleaner to do it by ndo. Driver has a flexibility to either compute
> > the phys port on fly of compute it once, store it in it's private data and use it
> > when ndo is called.

Doesn't the same argument apply to perm_addr?  And the flexibility there
turned out to be completely pointless.

> It seems to me that phys_port identifier is a net_device property,
> similar to netdev->dev_addr or netdev->if_port, and could be part of
> struct net_device  as discussed in [1].  My understanding may not be
> correct.
> 
> Hello Ben,  for the hybrid guest networking scenario, would it be
> required/helpful for phys_port to be part of net_device structure or
> either of the approaches would be fine.

I don't think it matters.  Either would be fine.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
