From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v3 net-next] sockopt: Change getsockopt() of
 SO_BINDTODEVICE to return an interface name
Date: Tue, 27 Nov 2012 20:34:39 +0000
Message-ID: <1354048479.2701.21.camel@bwh-desktop.uk.solarflarecom.com>
References: <50B388E4.7030600@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:28546 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755914Ab2K0Uen (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 15:34:43 -0500
In-Reply-To: <50B388E4.7030600@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-11-26 at 10:21 -0500, Brian Haley wrote:
> Instead of having the getsockopt() of SO_BINDTODEVICE return an index, which
> will then require another call like if_indextoname() to get the actual interface
> name, have it return the name directly.
> 
> This also matches the existing man page description on socket(7) which mentions
> the argument being an interface name.
> 
> If the value has not been set, zero is returned and optlen will be set to zero
> to indicate there is no interface name present.
> 
> Added a seqlock to protect this code path, and dev_ifname(), from someone
> changing the device name via dev_change_name().
> 
> v2: Added seqlock protection while copying device name.
> 
> v3: Fixed word wrap in patch.
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>
[...]

Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
