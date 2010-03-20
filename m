From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] ipv4: check rt_genid in dst_check
Date: Fri, 19 Mar 2010 21:08:34 -0700 (PDT)
Message-ID: <20100319.210834.115917044.davem@davemloft.net>
References: <1268990420-527-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44636
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751056Ab0CTEIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Mar 2010 00:08:11 -0400
In-Reply-To: <1268990420-527-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timo Teras <timo.teras@iki.fi>
Date: Fri, 19 Mar 2010 11:20:20 +0200

> Xfrm_dst keeps a reference to ipv4 rtable entries on each
> cached bundle. The only way to renew xfrm_dst when the underlying
> route has changed, is to implement dst_check for this. This is
> what ipv6 side does too.
> 
> The problems started after 87c1e12b5eeb7b30b4b41291bef8e0b41fc3dde9
> which fixed a bug causing xfrm_dst to not get reused, until that all
> lookups always generated new xfrm_dst with new route reference
> and path mtu worked. But after the fix, the old routes started
> to get reused even after they were expired causing pmtu to break
> (well it would occationally work if the rtable gc had run recently
> and marked the route obsolete causing dst_check to get called).
> 
> Signed-off-by: Timo Teras <timo.teras@iki.fi>
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks!
