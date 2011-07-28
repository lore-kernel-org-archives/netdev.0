From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: invalid requirement from ethtool?
Date: Thu, 28 Jul 2011 12:22:33 +0200
Message-ID: <1311848553.2619.1.camel@deadeye>
References: <20110726124222.GA4842@mtldesk30>
	 <20110727.224309.779719590419361909.davem@davemloft.net>
	 <20110728072326.GC6750@mtldesk30>
	 <20110728.003758.292509567308751079.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eli@dev.mellanox.co.il, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:57772 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754880Ab1G1KWj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 06:22:39 -0400
In-Reply-To: <20110728.003758.292509567308751079.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-07-28 at 00:37 -0700, David Miller wrote:
> From: Eli Cohen <eli@dev.mellanox.co.il>
> Date: Thu, 28 Jul 2011 10:23:26 +0300
> 
> > On Wed, Jul 27, 2011 at 10:43:09PM -0700, David Miller wrote:
> >> From: Eli Cohen <eli@dev.mellanox.co.il>
> >> Date: Tue, 26 Jul 2011 15:42:22 +0300
> >> 
> >> > I think both params zero should be allowed and mean coalescing is not
> >> > operational, thus we can remove these comments from ethtool.h
> >> 
> >> The existing precendence has existed for more than 10 years.  You can't
> >> just change it like this.
> >> 
> >> You'll need to find a new way to encode "disabled" coalescing.
> > 
> > I can't see the text explicitly specifies how to "disable" coalescing.
> > If I ignore the specific comment that disallows both params 0, I could
> > interpret the text such that when they're both zero, the feature is
> > disabled.
> 
> The documentation does not determine what the rules are, the cpu
> does not execute the documentation it executes the code, and that's
> what determines the rules.

The ethtool core doesn't check the values in struct ethtool_coalesce, so
the rules are really driver-specific.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

