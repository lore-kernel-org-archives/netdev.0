From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v3] drop_monitor: convert to modular building
Date: Thu, 17 May 2012 21:08:18 +0100
Message-ID: <1337285298.2496.24.camel@bwh-desktop.uk.solarflarecom.com>
References: <1337178426-2470-1-git-send-email-nhorman@tuxdriver.com>
	 <1337285040-20848-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:61193 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S965880Ab2EQUIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 16:08:22 -0400
In-Reply-To: <1337285040-20848-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-17 at 16:04 -0400, Neil Horman wrote:
> When I first wrote drop monitor I wrote it to just build monolithically.  There
> is no reason it can't be built modularly as well, so lets give it that
> flexibiity.
> 
> I've tested this by building it as both a module and monolithically, and it
> seems to work quite well
> 
> Change notes:
> 
> v2)
> * fixed for_each_present_cpu loops to be more correct as per Eric D.
> * Converted exit path failures to BUG_ON as per Ben H.
> 
> v3)
> * Converted del_timer to del_timer_sync to close race noted by Ben H.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> CC: "David S. Miller" <davem@davemloft.net>
> CC: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Ben Hutchings <bhutchings@solarflare.com>
[...]

Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

Thanks,
Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
