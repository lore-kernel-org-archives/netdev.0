From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH net] ipv6: simplify detection of first operational
 link-local address on interface
Date: Thu, 16 Jan 2014 19:20:32 -0200
Message-ID: <20140116212032.GP5359@plex.lan>
References: <20140116135323.GA7961@minipsycho.orion>
 <20140116191304.GC17529@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44761 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750898AbaAPVTd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 16:19:33 -0500
Content-Disposition: inline
In-Reply-To: <20140116191304.GC17529@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 16, 2014 at 08:13:04PM +0100, Hannes Frederic Sowa wrote:
> In commit 1ec047eb4751e3 ("ipv6: introduce per-interface counter for
> dad-completed ipv6 addresses") I build the detection of the first
> operational link-local address much to complex. Additionally this code
> now has a race condition.
> 
> Replace it with a much simpler variant, which just scans the address
> list when duplicate address detection completes, to check if this is
> the first valid link local address and send RS and MLD reports then.
> 
> Fixes: 1ec047eb4751e3 ("ipv6: introduce per-interface counter for dad-completed ipv6 addresses")
> Reported-by: Jiri Pirko <jiri@resnulli.us>
> Cc: Flavio Leitner <fbl@redhat.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---

Nice
Acked-by: Flavio Leitner <fbl@redhat.com>
