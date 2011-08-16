From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [patch net-next-2.6 2/3] net: remove use of
 ndo_set_multicast_list in drivers
Date: Tue, 16 Aug 2011 19:40:28 +0100
Message-ID: <1313520028.2725.35.camel@bwh-desktop>
References: <1313512142-3355-1-git-send-email-jpirko@redhat.com>
	 <1313512142-3355-3-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, eric.dumazet@gmail.com,
	kaber@trash.net, yoshfuji@linux-ipv6.org, rdunlap@xenotime.net,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, mirqus@gmail.com,
	jesse@nicira.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:47237 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752917Ab1HPSke (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2011 14:40:34 -0400
In-Reply-To: <1313512142-3355-3-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-08-16 at 18:29 +0200, Jiri Pirko wrote:
> replace it by ndo_set_rx_mode
[...]

Shouldn't this also rename the implementations whose names include
'multicast'?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

