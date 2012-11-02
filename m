From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] net: Fix continued iteration in
 rtnl_bridge_getlink()
Date: Fri, 2 Nov 2012 23:04:44 +0000
Message-ID: <1351897484.2703.23.camel@bwh-desktop.uk.solarflarecom.com>
References: <1351897012.2703.17.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:50383 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750988Ab2KBXEr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2012 19:04:47 -0400
In-Reply-To: <1351897012.2703.17.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-11-02 at 22:56 +0000, Ben Hutchings wrote:
[...]
> I'm still not sure it's correct to break iteration if
> ndo_bridge_getlink returns -EOPNOTSUPP (possible if the driver supports
> a mixture of bridging and non-bridging devices).
[...]

Never mind that - the driver can just return 0 for those devices, as
ixgbe is doing.  But the bug this patch addresses seems to be real.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
