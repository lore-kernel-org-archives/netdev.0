From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 0/2] 802.1ad S-VLAN support
Date: Mon, 7 Nov 2011 15:11:44 +0000
Message-ID: <1320678704.3020.33.camel@bwh-desktop>
References: <1320512055-1231037-1-git-send-email-equinox@diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:25885 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819Ab1KGPLs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2011 10:11:48 -0500
In-Reply-To: <1320512055-1231037-1-git-send-email-equinox@diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2011-11-05 at 17:54 +0100, David Lamparter wrote:
> Hi DaveM, hi everyone,
> 
> 
> this kernel patch, together with the iproute2 userspace support,
> allows creating 802.1ad S-VLAN devices.
> 
> This feature might have weird interactions with hardware VLAN
> acceleration. I've done my best to make sure it doesn't break
> 802.1Q, but my access to hardware is rather limited. I did grep
> & scan all drivers for maybe-affected vlan behaviour and found
> nothing. I've tested on e1000, forcedeth, virtio and a Kirkwood
> ARM.

I didn't try it at all, but it looks reasonable to me.

We definitely need to think about how MTU/MRU are configured when
multiple VLAN tags are used, though I don't think it's essential to do
before this goes in.  To be slightly more blunt than your documentation,
our current handling of MTU/MRU and VLANs is a botch.

Do you have any plan to improve that?  Or to allow use of offload
features for multiple-tagged packets?

Ben.

> It'd be nice to get this into the next merge window to get some
> people with funny hardware a nice smoke trail...

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
