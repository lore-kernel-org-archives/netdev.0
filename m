From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] af_packet: flush complete kernel cache in packet_sendmsg
Date: Fri, 02 Sep 2011 14:46:17 +0100
Message-ID: <1314971179.3092.159.camel@deadeye>
References: <20110505141107.GC30443@orbit.nwl.cc>
	 <1314961686-30870-1-git-send-email-phil.sutter@viprinet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	Russell King <linux@arm.linux.org.uk>,
	"David S. Miller" <davem@davemloft.net>
To: Phil Sutter <phil.sutter@viprinet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:47176 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752116Ab1IBNqW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2011 09:46:22 -0400
In-Reply-To: <1314961686-30870-1-git-send-email-phil.sutter@viprinet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-09-02 at 13:08 +0200, Phil Sutter wrote:
> This flushes the cache before and after accessing the mmapped packet
> buffer. It seems like the call to flush_dcache_page from inside
> __packet_get_status is not enough on Kirkwood (or ARM in general).
> ---
> I know this is far from an optimal solution, but it's in fact the only working
> one I found.
[...]

This is ridiculous.  If flush_dcache_page() isn't doing everything it
should, you need to fix that.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
