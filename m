From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: ICMPv6: treat dest unreachable codes 5 and 6 as EACCES, not EPROTO
Date: Sun, 1 Sep 2013 20:54:32 +0200
Message-ID: <20130901185432.GC19455@order.stressinduktion.org>
References: <20130830091844.GA2706@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:59553 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756605Ab3IASyd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Sep 2013 14:54:33 -0400
Content-Disposition: inline
In-Reply-To: <20130830091844.GA2706@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 30, 2013 at 11:18:45AM +0200, Jiri Bohac wrote:
> RFC 4443 has defined two additional codes for ICMPv6 type 1 (destination
> unreachable) messages:
>         5 - Source address failed ingress/egress policy
> 	6 - Reject route to destination
> 
> Now they are treated as protocol error and icmpv6_err_convert() converts them
> to EPROTO.
> 
> RFC 4443 says:
> 	"Codes 5 and 6 are more informative subsets of code 1."
> 
> Treat codes 5 and 6 as code 1 (EACCES)
> 
> Btw, connect() returning -EPROTO confuses firefox, so that fallback to
> other/IPv4 addresses does not work:
> https://bugzilla.mozilla.org/show_bug.cgi?id=910773
> 
> 
> Signed-off-by: Jiri Bohac <jbohac@suse.cz>

I would also propose it for stable.

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks,

  Hannes
