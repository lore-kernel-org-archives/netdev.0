From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 2/3] net: remove use of
 ndo_set_multicast_list in drivers
Date: Tue, 16 Aug 2011 22:07:45 +0200
Message-ID: <20110816200744.GA1971@minipsycho>
References: <1313512142-3355-1-git-send-email-jpirko@redhat.com>
 <1313512142-3355-3-git-send-email-jpirko@redhat.com>
 <1313520028.2725.35.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, eric.dumazet@gmail.com,
	kaber@trash.net, yoshfuji@linux-ipv6.org, rdunlap@xenotime.net,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, mirqus@gmail.com,
	jesse@nicira.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40003 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751485Ab1HPUJA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Aug 2011 16:09:00 -0400
Content-Disposition: inline
In-Reply-To: <1313520028.2725.35.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Aug 16, 2011 at 08:40:28PM CEST, bhutchings@solarflare.com wrote:
>On Tue, 2011-08-16 at 18:29 +0200, Jiri Pirko wrote:
>> replace it by ndo_set_rx_mode
>[...]
>
>Shouldn't this also rename the implementations whose names include
>'multicast'?

I was thinking about that. But sometimes it's not absolutelly trivial.
Also, I think that perserving the existing names would cause any
troubles so I left that as it is. Feel free to do incremental patch :)

>
>Ben.
>
>-- 
>Ben Hutchings, Staff Engineer, Solarflare
>Not speaking for my employer; that's the marketing department's job.
>They asked us to note that Solarflare product names are trademarked.
>
